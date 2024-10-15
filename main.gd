extends Node2D

# Variables for the circles
var circle_count = 50  # Number of circles
var circles = []  # Array to store circle data (position, radius, color)
var radius = 20  # Radius of each circle
var speed = 100  # Movement speed in pixels per second
var screen_size = Vector2(1920, 1080)  # Size of the window/screen
var angle = 0
var sight_radius = 125.0
var directions = []


func _ready():
	# Generate circles with random positions
	for i in range(circle_count):
		#angle = randf_range(0, TAU)
		var circle_data = {
			"position": Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y)),  # Random position within screen area
			"color": Color(1, 1, randf()),  # Random color
			"angle": randf_range(0, TAU)
		}
		circles.append(circle_data)
	
	set_process(true)

func _draw():
	# Draw each circle
	for circle in circles:
		draw_circle(circle["position"], radius, circle["color"])
	
	for circle in circles:
		draw_circle(circle["position"], sight_radius, Color(1, 1, 1, 0.01))
	
	for i in range(circles.size()):
		var circle = circles[i]
		for j in range(circles.size()):
			if i == j:
				continue
			
			var circleToCheck = circles[j]
			var distanceBetweenCircles = circle["position"].distance_to(circleToCheck["position"])
			
			if distanceBetweenCircles < sight_radius:
				draw_line(circle["position"], circleToCheck["position"], Color(1, 0, 0))

func _process(delta):
	# Move all circles in the fixed direction
	for i in range(circles.size()):
		#var direction = Vector2(randf(), randf())
		var circle = circles[i]
		var angleOfCurrentCircle = circle["angle"]
		# Move the circle in the direction
		circle["position"] += Vector2(sin(angleOfCurrentCircle), cos(angleOfCurrentCircle)) * speed * delta

		# Check if the circle has reached the edge of the screen and teleport to the other side
		if circle["position"].x > screen_size.x + radius:  # Exiting right
			circle["position"].x = -radius  # Teleport to the left
		elif circle["position"].x < -radius:  # Exiting left
			circle["position"].x = screen_size.x + radius  # Teleport to the right

		if circle["position"].y > screen_size.y + radius:  # Exiting bottom
			circle["position"].y = -radius  # Teleport to the top
		elif circle["position"].y < -radius:  # Exiting top
			circle["position"].y = screen_size.y + radius  # Teleport to the bottom
		
	#for i in range(circles.size()):
		
		
		
	
	# Request a redraw of the circles after moving them
	queue_redraw()
