class_name OrientedSpatial

tool
extends Spatial

var planet : Spatial


func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return
	
	planet = get_tree().root.find_node("Planet", true, false)


func _process(delta: float) -> void:
	if planet != null:
		var up := (global_translation - planet.global_translation).normalized()
		var current_up = (global_transform.basis * Vector3.UP).normalized()
		if not up.is_equal_approx(current_up):
			global_transform.basis = global_transform.basis.rotated(up.cross(current_up).normalized(), -up.angle_to(current_up))
