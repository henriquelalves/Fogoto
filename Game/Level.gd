extends Spatial

const OFFLINE_SCOREBOARD_MANAGER = preload("res://Scoreboard/OfflineScoreboardManager.gd")
const SCOREBOARD_SCENE = preload("res://Game/Scoreboard.tscn")

const VICTORY_HEIGHT = 81.0
const SKY_INITIAL_COLOR = Color(0.24, 0.87, 0.82)
const SKY_FINAL_COLOR = Color(0.24, 0.38, 0.87)

onready var height_panel = $"%HeightPanel"
onready var background_color_rect = $"%BackgroundColorRect"
onready var planet = $"%Planet"
onready var player = $"%Player"
onready var congratulations_animation = $"%CongratulationsAnimation"
onready var final_score_label = $"%FinalScoreLabel"
onready var overlay = $"%Overlay"
onready var ui_container = $"%UIContainer"
onready var fanfare_player = $"%FanfarePlayer"
onready var instructions = $"%Instructions"
onready var current_time_label = $"%CurrentTimeLabel"

onready var _initial_ticks_msec = 0.0
onready var _total_time_msec = 0.0
onready var _scoreboard_manager
onready var _timer_started = false


func _ready():
	overlay.show()
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	instructions.present()

	_scoreboard_manager = OFFLINE_SCOREBOARD_MANAGER.new()
	add_child(_scoreboard_manager)


func _physics_process(delta):
	height_panel.current_height = planet.global_translation.distance_to(player.global_translation)

	if height_panel.current_height > VICTORY_HEIGHT and not player.win_animation:
		instructions.dismiss()
		var planet_to_player_dir = planet.global_translation.direction_to(player.global_translation)
		player.set_win_animation(player.global_translation + planet_to_player_dir * 50.0)
		var ui_tween := create_tween()
		ui_tween.tween_property(height_panel, "modulate:a", 0.0, 1.0)
		_total_time_msec = Time.get_ticks_msec() - _initial_ticks_msec
		
		yield(player, "win_animation_finished")
		yield(get_tree().create_timer(1.0), "timeout")
		fanfare_player.play()
		congratulations_animation.play("yeah")
		yield(get_tree().create_timer(3.0), "timeout")
		final_score_label.show()
		final_score_label.text = "Final Time: " + Utils.time_msec_to_string(_total_time_msec)
		yield(get_tree().create_timer(2.0), "timeout")
		var scoreboard = SCOREBOARD_SCENE.instance()
		ui_container.add_child(scoreboard)
		scoreboard.present(_total_time_msec, _scoreboard_manager)
		
	else:
		background_color_rect.color = SKY_INITIAL_COLOR.linear_interpolate(SKY_FINAL_COLOR, height_panel.current_height / VICTORY_HEIGHT)
		if _timer_started:
			current_time_label.text = "%0.2fs" % ((Time.get_ticks_msec() - _initial_ticks_msec)*0.001)


func _input(event):
	if not player.win_animation and event is InputEventKey and event.is_pressed() and not event.is_echo():
		instructions.dismiss()
		if not _timer_started:
			_timer_started = true
			_initial_ticks_msec = Time.get_ticks_msec()
		if event.scancode == KEY_R:
			set_physics_process(false)
			var tween = create_tween()
			tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
			yield(tween,"finished")
			get_tree().reload_current_scene()
