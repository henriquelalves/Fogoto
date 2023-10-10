class_name Player
extends RigidBody

signal win_animation_finished

const FIREWORKS_SCENE = preload("res://Game/Fireworks.tscn")

export var fuel_max_value = 100.0
export var fuel_spend_ratio = 30.0
export var fuel_recover_ground = 50.0

onready var camera_anchor: Spatial = $"%CameraAnchor"
onready var camera: Camera = $"%Camera"
onready var player_light: SpotLight = $"%PlayerLight"
onready var center: Spatial = $"%Center"
onready var ignition_sprite_root = $"%IgnitionSpriteRoot"
onready var player_model = $"%PlayerRocketModel"
onready var explosion_animation = $"%ExplosionAnimationPlayer"
onready var sound_engine = $"%SoundEngine"
onready var fuel_bar: ProgressBar = $"%FuelBar"

onready var _current_fuel : float = fuel_max_value
onready var _debug_positions := {}
onready var _checkpoint_cycle = 0
onready var win_animation = false


func set_win_animation(final_pos: Vector3) -> void:
	win_animation = true
	ignition_sprite_root.play_ignition()
	sleeping = true

	var tween := create_tween()
	tween.tween_property(self, "global_translation", final_pos, 5.0)
	tween.parallel().tween_property(fuel_bar, "modulate:a", 0.0, 1.0)
	yield(tween, "finished")
	sound_engine.stop()
	ignition_sprite_root.stop_ignition()
	player_model.hide()
	explosion_animation.play("explode")
	var fireworks = FIREWORKS_SCENE.instance()
	add_child(fireworks)
	emit_signal("win_animation_finished")


func _ready() -> void:
	camera_anchor.global_transform = Transform()
	camera_anchor.set_as_toplevel(true)
	player_light.set_as_toplevel(true)
	
	# Fix for gravity override not working with multiple collision shapes
	var shapes = ["BaseShape1", "BaseShape2", "BaseShape3", "BaseShape4"]
	for shape_name in shapes:
		yield(get_tree(),"idle_frame")
		get_node(shape_name).set_deferred("disabled", false)


func _physics_process(delta: float) -> void:

	var body_state := PhysicsServer.body_get_direct_state(get_rid())
	var body_contacting := body_state.get_contact_count() > 0
	
	# =========================
	# WIN ANIMATION
	if win_animation:
		camera.look_at(
			center.global_translation,
			(camera.global_transform.basis * Vector3.RIGHT).cross(camera.global_translation.direction_to(center.global_translation))
			)
		return
	
	
	# =========================
	# TORQUE
	var input_vec := Input.get_vector("ui_left","ui_right","ui_down","ui_up")
	var torque := Vector3(-input_vec.y, 0, -input_vec.x).normalized()
	
	if input_vec.length() > 0.0:
		var camera_forward := camera_anchor.transform.basis * Vector3.FORWARD
		var camera_left := camera_anchor.transform.basis * Vector3.LEFT

		add_torque((camera_left * 10 * input_vec.y) + (camera_forward * 10 * input_vec.x))
	
	elif not body_contacting:
		angular_velocity = lerp(angular_velocity, Vector3.ZERO, 0.1)
	
	PhysicsServer.body_set_state(get_rid(), PhysicsServer.BODY_STATE_ANGULAR_VELOCITY, body_state.angular_velocity.limit_length(10.0))

	# =========================
	# ENGINE
	
	var is_engine_on := Input.is_key_pressed(KEY_SPACE) and _current_fuel > 0
	if is_engine_on:
		add_central_force(global_transform.basis * Vector3.UP * 12)
		_current_fuel -= fuel_spend_ratio * delta
	elif not Input.is_key_pressed(KEY_SPACE):
		if body_contacting:
			_current_fuel += fuel_recover_ground * delta
	
	if is_engine_on and not sound_engine.playing:
		sound_engine.play()
	elif not is_engine_on:
		sound_engine.stop()
		
	_current_fuel = clamp(_current_fuel, 0.0, fuel_max_value)

	# =========================
	# CAMERA
	
	var inv_gravity : Vector3 = -body_state.total_gravity.normalized()
	var camera_anchor_up : Vector3 = (camera_anchor.transform.basis * Vector3.UP).normalized()

	if not inv_gravity.is_equal_approx(camera_anchor_up):
		var cross_grav = camera_anchor_up.cross(inv_gravity).normalized()
		if not cross_grav.is_equal_approx(Vector3.ZERO):
			camera_anchor.global_transform.basis = camera_anchor.global_transform.basis.rotated(cross_grav, camera_anchor_up.angle_to(inv_gravity))
	
	camera_anchor.global_translation = global_translation

	var turning = 0
	if Input.is_key_pressed(KEY_Q): turning = -1
	elif Input.is_key_pressed(KEY_E): turning = 1
	
	camera_anchor.rotate_y(turning * delta * 2)
	
	player_light.global_translation = center.global_translation + (inv_gravity * 6)
	player_light.global_transform.basis = camera_anchor.global_transform.basis.rotated(camera_anchor.global_transform.basis * Vector3.RIGHT, -PI/2.0)

	# =========================
	# VISUALS
	
	if is_engine_on:
		ignition_sprite_root.play_ignition()
	else:
		ignition_sprite_root.stop_ignition()
	
	var ign_to_cam_dir = ignition_sprite_root.global_translation.direction_to(camera.global_translation).normalized()
	var ign_forward = (ignition_sprite_root.global_transform.basis * Vector3.BACK).normalized()
	var ign_down = (ignition_sprite_root.global_transform.basis * Vector3.DOWN).normalized()

	var ign_to_cam_angle = ign_forward.signed_angle_to(ign_to_cam_dir, ign_down)
	ignition_sprite_root.global_rotate(ign_down, ign_to_cam_angle)
	
	fuel_bar.value = _current_fuel / fuel_max_value

