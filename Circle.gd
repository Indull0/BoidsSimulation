extends Node2D
var rng = RandomNumberGenerator.new()
var numberOfCircles = 50
var circles = []
var radius = 20
var speed = 50
var screen_size = Vector2(1024, 600)

var direction = Vector2(2, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_draw()
	for i in range(numberOfCircles):
		var circle_data = {
			"position": Vector2(randi_range(0, 1000), randi_range(0, 600)),
			"color": Color(1, 1, randf()),
		}
		circles.append(circle_data)
	set_process(true)

func _draw():
	
	for circle in circles:
		draw_circle(circle["position"], radius, circle["color"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(circles.size()):
		var circle = circles[i]
		
		circle["position"] += direction * speed * delta
		
		if circle["position"].x > screen_size.x + radius:
			circle["position"].x = -radius
		elif circle["position"].x < -radius:
			circle["position"].x = screen_size.x + radius
		
		if circle["position"].y > screen_size.y + radius:
			circle["position"].y = -radius
		elif circle["position"].y < -radius:
			circle["position"].y = screen_size.y + radius
			
	update()
