extends HBoxContainer

signal score_name_set

onready var score_name = $"%ScoreName"
onready var score_value = $"%ScoreValue"


func set_input_enabled(enabled: bool) -> void:
	score_name.editable = enabled
	var custom_theme = score_name.get("custom_styles/normal")
	custom_theme.set("border_color", Color(1.0, 0.96, 0.38) if enabled else Color.transparent)
	score_name.set("custom_styles/normal", custom_theme)


func _input(event) -> void:
	if score_name.editable and event is InputEventKey and event.is_pressed() and event.scancode == KEY_ENTER:
		emit_signal("score_name_set")
