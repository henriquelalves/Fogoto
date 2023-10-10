extends Panel


export var min_height = 0.0
export var max_height = 100.0

onready var height_ship_root = $"%HeightShipRoot"
onready var height_label = $"%HeightLabel"
onready var current_height = 0.0


func _process(delta):
	height_ship_root.rect_position = Vector2(
		rect_size.x / 2.0,
		rect_size.y * (1.0 - clamp((current_height - min_height) / (max_height - min_height), 0.0, 1.0))
		)
	height_label.text = "%0.0f m" % (current_height - min_height)
