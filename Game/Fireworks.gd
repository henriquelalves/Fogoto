extends Spatial

const FIREWORK_PARTICLES_SCENE = preload("res://Game/FireworkParticles.tscn")


func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_shoot_firework")
	timer.start(1.0)
	
	var particles = FIREWORK_PARTICLES_SCENE.instance()
	add_child(particles)
	particles.set("material_override:albedo_color", Color(randf(), randf(), randf()))
	particles.restart()
	yield(get_tree().create_timer(1.5),"timeout")
	particles.queue_free()


func _shoot_firework() -> void:
	var particles = FIREWORK_PARTICLES_SCENE.instance()
	add_child(particles)
	
	particles.translation += Vector3(randf()*10, randf()*10, randf()*10)
	
	particles.set("color", Color(randf(), randf(), randf()))
	particles.restart()
	yield(get_tree().create_timer(1.5),"timeout")
	particles.queue_free()
