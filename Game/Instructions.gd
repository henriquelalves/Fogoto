extends Control

var tween: SceneTreeTween

onready var dismissing := false


func present() -> void:
	if visible:
		return
	
	if tween != null and tween.is_running():
		tween.stop()
	
	show()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)


func dismiss() -> void:
	if dismissing:
		return
	
	dismissing = true
	
	if tween != null and tween.is_running():
		tween.stop()
	
	tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self, "hide")
