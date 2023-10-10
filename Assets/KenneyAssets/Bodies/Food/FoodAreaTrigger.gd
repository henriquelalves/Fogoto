extends Area

const FALL_DISTANCE = 2.0

var _original_pos : Vector3
var _oriented_transform : Transform
var tween : SceneTreeTween = null


func _ready():
	_original_pos = get_parent().global_translation
	_oriented_transform = get_parent().get_parent().global_transform
	
	
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body) -> void:
	if not body is Player:
		return
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(get_parent(), "global_translation", _original_pos + (_oriented_transform.basis * Vector3.DOWN)*FALL_DISTANCE, 1.0)


func _on_body_exited(body) -> void:
	if not body is Player:
		return
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(get_parent(), "global_translation", _original_pos, 0.5)
