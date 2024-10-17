extends Node2D

# Variables for the boids
var boid_count = 75  # Number of boids
var boids = []  # Array to store boid data (position, radius, color)
var radius = 20  # Radius of each boid
var speed = 150  # Movement speed in pixels per second
var screen_size = Vector2(1920, 1080)  # Size of the window/screen
var angle = 0
var sight_radius = 150.0
var directions = []
var fov = PI + PI / 4
var turn_speed = PI / 16
var avoidance_force = 0.15
var localCenterRadius = 200
var centeringGlobalUrge = 0.005
var centeringLocalUrge = 0.015


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func draw_triangle(position, angle, size, color):
	var half_size = size / 2
	# Define the vertices of the triangle based on the angle
	var vertices = []
	vertices.append(position + Vector2(cos(angle), sin(angle)) * size)  # Front tip
	vertices.append(position + Vector2(cos(angle + 2*PI/3), sin(angle + 2*PI/3)) * half_size)  # Left base
	vertices.append(position + Vector2(cos(angle - 2*PI/3), sin(angle - 2*PI/3)) * half_size)  # Right base
	
	# Draw the triangle
	draw_polygon(PackedVector2Array(vertices), [color])

func _ready():
	# Generate boids with random positions
	for i in range(boid_count):
		var boid_data = {
			"position": Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y)),  # Random position within screen area
			"color": Color(randf_range(50, 80) / 255, randf_range(80, 165) / 255, randf_range(200, 230) / 255, 1),  # Random color
			"angle": randf_range(0, TAU)
		}
		boids.append(boid_data)
	
	set_process(true)

func _draw():
	# Draw vision cone for specific boid
	#var speicalBoid = boids[5]
	#var from_angle = speicalBoid["angle"] - fov / 2
	#var to_angle = speicalBoid["angle"] + fov / 2
	#draw_circle_arc_poly(speicalBoid["position"], sight_radius, from_angle, to_angle, Color(1, 1, 1, 0.1))
	
	# Draw all boids
	for i in range(boids.size()):
		var boid = boids[i]
		#if i == 5: 
		#	draw_triangle(boid["position"], boid["angle"], radius, Color(0.8, 0.3, 0.3))
		#else:
		draw_triangle(boid["position"], boid["angle"], radius, boid["color"])
		
					#if i == 5:
						#draw_line(boid["position"], boidToCheck["position"], Color(1, 0, 0))
				#if (abs(angleToBoid) > -fov / 2):
					#avoid_angle += sign(angleToBoid) * avoidance_force
					#if i == 5:
						#draw_line(boid["position"], boidToCheck["position"], Color(1, 0, 0))



func _process(delta):
	# Move all boids in the fixed direction
	for i in range(boids.size()):
		# Define/reset a couple useful variables
		var boid = boids[i]
		var avoid_angle = 0.0
		var boidsInLocalRadius = 0
		var currentBoidDirection = Vector2(cos(boid["angle"]), sin(boid["angle"]))
		var centerOfLocalFlock = Vector2(0.0, 0.0)
		var angleToCenterOfLocalFlock = 0.0
		
		var boidsInGlobalRadius = 0
		var centerOfGlobalFlock = Vector2(0.0, 0.0)
		var angleToCenterOfGlobalFlock = 0.0
		
		# Move the boid in the direction
		boid["position"] += Vector2(cos(boid["angle"]), sin(boid["angle"])) * speed * delta
		# Check if the boid has reached the edge of the screen and teleport to the other side
		if boid["position"].x > screen_size.x + radius:  # Exiting right
			boid["position"].x = -radius  # Teleport to the left
		elif boid["position"].x < -radius:  # Exiting left
			boid["position"].x = screen_size.x + radius  # Teleport to the right

		if boid["position"].y > screen_size.y + radius:  # Exiting bottom
			boid["position"].y = -radius  # Teleport to the top
		elif boid["position"].y < -radius:  # Exiting top
			boid["position"].y = screen_size.y + radius  # Teleport to the bottom
	
		for j in range(boids.size()):
			# Don't check self
			if i == j:
				continue
			var boidToCheck = boids[j]
			
			centerOfGlobalFlock += boidToCheck["position"]
			boidsInGlobalRadius += 1
		
			# Distance check
			var distanceBetweenBoids = boid["position"].distance_to(boidToCheck["position"])
			
			# Logic for nudging boid to the center of the flock
			if distanceBetweenBoids < localCenterRadius:
				centerOfLocalFlock += boidToCheck["position"]
				boidsInLocalRadius += 1
				
				
				# Avoidance Logic
				if distanceBetweenBoids < sight_radius:
					var vectorBetweenBoids = (boidToCheck["position"] - boid["position"])
					var angleToBoid = currentBoidDirection.angle_to(vectorBetweenBoids.normalized())
					if abs(angleToBoid) < fov / 2:
						avoid_angle -= sign(angleToBoid) * avoidance_force * (1 - distanceBetweenBoids / 125) * (1 - angleToBoid / fov)# * (1 - distanceBetweenBoids / 125))
						
		# Steer to local center
		if boidsInLocalRadius > 0:
			centerOfLocalFlock /= boidsInLocalRadius
			var vectorToCenterOfLocalFlock = (centerOfLocalFlock - boid["position"]).normalized()
			angleToCenterOfLocalFlock = currentBoidDirection.angle_to(vectorToCenterOfLocalFlock)
			boid["angle"] += angleToCenterOfLocalFlock * centeringLocalUrge
		# Steer to global center
		if boidsInGlobalRadius > 0:
			centerOfGlobalFlock /= boidsInGlobalRadius
			var vectorToCenterOfGlobalFlock = (centerOfGlobalFlock - boid["position"]).normalized()
			angleToCenterOfGlobalFlock = currentBoidDirection.angle_to(vectorToCenterOfGlobalFlock)
			boid["angle"] += angleToCenterOfGlobalFlock * centeringGlobalUrge
		
		boid["angle"] += avoid_angle * turn_speed
	
	# Request a redraw of the boids after moving them
	queue_redraw()
