extends "ScoreboardManager.gd"

var _scores = []


func fetch_scores() -> void:
	yield(get_tree(),"idle_frame")
	emit_signal("fetched")


func get_scores() -> Array:
	return _scores.duplicate()


func set_score(score_name, score_value) -> void:
	var i = 0
	while i < _scores.size():
		if _scores[i]["value"] > score_value:
			break
		i += 1
	
	if i > 9:
		return
	
	_scores.insert(i, {"name": score_name, "value": score_value})
	
	if _scores.size() > 10:
		_scores.pop_back()
	
	_save_file()


func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_P:
		_scores = []
		_save_file()


func _ready():
	var dir = Directory.new()
	if dir.file_exists("user://hiscores"):
		_load_file()
	else:
		_save_file()


func _save_file():
	var file = File.new()
	file.open("user://hiscores", File.WRITE)
	file.store_var(_scores)
	file.close()


func _load_file():
	var file = File.new()
	file.open("user://hiscores", File.READ)
	_scores = file.get_var()
	file.close()
