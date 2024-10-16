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
var fov = PI + PI / 2
var turn_speed = PI / 4
var avoidance_force = 0.05


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


func _ready():
	# Generate circles with random positions
	for i in range(circle_count):
		#angle = randf_range(0, TAU)
		var circle_data = {
			"position": Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y)),  # Random position within screen area
			"color": Color(randf_range(50, 80) / 255, randf_range(80, 165) / 255, randf_range(200, 230) / 255, 1),  # Random color
			"angle": randf_range(0, TAU)
		}
		circles.append(circle_data)
	
	set_process(true)

func _draw():
	# Draw each circle
	#for circle in circles:
	var specialCircle = circles[5]
	var from_angle = specialCircle["angle"] - fov / 2
	var to_angle = specialCircle["angle"] + fov / 2
	draw_circle_arc_poly(specialCircle["position"], sight_radius, from_angle, to_angle, Color(1, 1, 1, 0.1))
	for i in range(circles.size()):
		var circle = circles[i]
		draw_circle(circle["position"], radius, circle["color"])
		var avoid_angle = 0.0
	
		for j in range(circles.size()):
			if i == j:
				continue
			var circleToCheck = circles[j]
			var distanceBetweenCircles = circle["position"].distance_to(circleToCheck["position"])
			
			if distanceBetweenCircles < sight_radius:
				var currentCircleDirection = Vector2(cos(circle["angle"]), sin(circle["angle"]))
				var vectorBetweenCircles = (circleToCheck["position"] - circle["position"]).normalized()
				var angleToCircle = currentCircleDirection.angle_to(vectorBetweenCircles)
				if (angleToCircle < fov / 2):
					avoid_angle += sign(angleToCircle) * avoidance_force
					if i == 5:
						draw_line(circle["position"], circleToCheck["position"], Color(1, 0, 0))
				if (angleToCircle > -fov / 2):
					avoid_angle -= sign(angleToCircle) * avoidance_force
					if i == 5:
						draw_line(circle["position"], circleToCheck["position"], Color(1, 0, 0))
		circle["angle"] += avoid_angle * turn_speed


func _process(delta):
	# Move all circles in the fixed direction
	for i in range(circles.size()):
		#var direction = Vector2(randf(), randf())
		var circle = circles[i]
		# Move the circle in the direction
		circle["position"] += Vector2(cos(circle["angle"]), sin(circle["angle"])) * speed * delta

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
