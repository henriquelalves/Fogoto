extends Control

const SCORE_ITEM_SCENE = preload("res://Game/ScoreItem.tscn")

onready var score_list = $"%ScoreList"
onready var restart_label = $"%RestartLabel"

onready var _waiting = false
onready var _score_manager


func _ready():
	rect_scale = Vector2.ZERO


func present(score_msec: int, score_manager) -> void:
	_score_manager = score_manager
	score_manager.fetch_scores()
	yield(score_manager, "fetched")
	
	var scores = score_manager.get_scores()
	
	var i = 0
	while i < scores.size():
		var score = scores[i]
		if score['value'] > score_msec:
			break
		i += 1
	scores.insert(i, {'name': '', 'value': score_msec})
	
	for n in range(min(10, scores.size())):
		var score_item = SCORE_ITEM_SCENE.instance()
		score_list.add_child(score_item)
		score_item.score_name.text = scores[n]['name']
		score_item.score_value.text = Utils.time_msec_to_string(scores[n]['value'])
		if score_item.score_name.text == '':
			_waiting = true
		score_item.set_input_enabled(score_item.score_name.text == '')
		score_item.connect("score_name_set", self, "_on_score_name_set", [score_item, scores[n]])
	
	restart_label.visible = not _waiting
	
	var tween = create_tween()
	tween.tween_property(self, "rect_scale", Vector2.ONE, 1.0)


func _on_score_name_set(score_item, score) -> void:
	score_item.set_input_enabled(false)
	_waiting = false
	_score_manager.set_score(score_item.score_name.text, score['value'])
	restart_label.show()


func _input(event):
	if not _waiting and event is InputEventKey and event.is_pressed() and event.scancode == KEY_R:
		get_tree().reload_current_scene()
