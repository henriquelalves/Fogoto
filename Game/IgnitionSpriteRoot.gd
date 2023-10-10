extends Spatial

onready var ignition_animation_player = $"%IgnitionAnimationPlayer"

var tween : SceneTreeTween


func _ready():
	scale = Vector3.ONE * 0.001


func play_ignition() -> void:
	if ignition_animation_player.is_playing():
		return
	
	if tween != null and tween.is_running():
		tween.stop()
	
	ignition_animation_player.play("ignite")
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.4)


func stop_ignition() -> void:
	if not ignition_animation_player.is_playing():
		return
	
	if tween != null and tween.is_running():
		tween.stop()
	
	ignition_animation_player.stop()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * 0.001, 0.2)
	tween.tween_callback(ignition_animation_player, "stop")
