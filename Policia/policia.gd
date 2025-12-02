extends CharacterBody2D

const FORWARD_DIRECTION = Vector2.RIGHT

enum States { WANDER, CHASE }
var current_state = States.WANDER
var player_target = null

@export var patrol_point_a: Vector2
@export var patrol_point_b: Vector2
var patrol_target: Vector2

@export var wait_time_patrol : float

@export var wander_speed = 50.0
@export var chase_speed = 120.0
@export var fov_angle = 60.0
@export var fov_length = 250.0

@onready var detection_radius = $DetectionRadius
@onready var line_of_sight = $LineOfSight
@onready var detection_shape = $DetectionRadius/CollisionShape2D
@onready var vision_cone = $VisionCone
@onready var anim = $AnimatedSprite2D
@onready var waitTimerPatrol = $WaitTimerPatrol

var facing_dir = FORWARD_DIRECTION
var _last_facing_dir = Vector2.ZERO
var is_waiting = false


func _ready():
	patrol_point_a = to_global(patrol_point_a)
	patrol_point_b = to_global(patrol_point_b)
	patrol_target = patrol_point_b
	_update_vision_cone()

func _physics_process(delta):
	match current_state:
		States.WANDER:
			_wander_state(delta)
		States.CHASE:
			_chase_state(delta)

	_update_animation()
	_update_vision_cone_if_needed()

	move_and_slide()

	if current_state == States.CHASE:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision == null:
				continue
			var collider = collision.get_collider()
			if collider and collider.is_in_group("player"):
				_go_to_game_over()
				break

# --- Vision cone ---

func _update_vision_cone():
	var radius = fov_length
	var p1 = facing_dir.rotated(deg_to_rad(fov_angle)).normalized() * radius
	var p2 = facing_dir.rotated(deg_to_rad(-fov_angle)).normalized() * radius
	vision_cone.polygon = PackedVector2Array([Vector2.ZERO, p1, p2])

func _update_vision_cone_if_needed():
	if facing_dir != _last_facing_dir:
		_last_facing_dir = facing_dir
		_update_vision_cone()

# ------------------ ESTADOS -----------------------

func _wander_state(delta):
	vision_cone.modulate = Color(1,1,1,0.3)

	# mesmo parado, checa player
	var target = _find_player_target()
	if target:
		player_target = target
		current_state = States.CHASE
		return

	if is_waiting:
		velocity = Vector2.ZERO
		return

	# movimento normal
	var dir = (patrol_target - global_position).normalized()
	velocity = dir * wander_speed

	# chegou no ponto de patrulha
	if global_position.distance_to(patrol_target) < 5:
		is_waiting = true
		velocity = Vector2.ZERO
		waitTimerPatrol.start(wait_time_patrol)
	
func _on_wait_timer_patrol_timeout():
	# troca destino exclusivamente quando chega em A ou B
	if patrol_target == patrol_point_a:
		patrol_target = patrol_point_b
	else:
		patrol_target = patrol_point_a
	is_waiting = false

func _chase_state(delta):
	vision_cone.modulate = Color(1,0,0,0.4)

	if player_target:
		if _can_see_player(player_target):
			var dir = (player_target.global_position - global_position).normalized()
			velocity = dir * chase_speed
		else:
			player_target = null
			current_state = States.WANDER
	else:
		current_state = States.WANDER

# ------------------ AUX ---------------------------

func _find_player_target():
	for body in detection_radius.get_overlapping_bodies():
		if body.is_in_group("player") and _can_see_player(body):
			return body
	return null

func _can_see_player(player):
	var dist = global_position.distance_to(player.global_position)
	if dist > fov_length:
		return false

	var dir_to_player = (player.global_position - global_position).normalized()
	var forward = facing_dir.normalized()
	var angle = abs(rad_to_deg(forward.angle_to(dir_to_player)))
	if angle > fov_angle:
		return false

	line_of_sight.target_position = to_local(player.global_position)
	line_of_sight.force_raycast_update()

	if line_of_sight.is_colliding():
		return line_of_sight.get_collider() == player
	return false

# ------------------ GAME OVER ---------------------

func _go_to_game_over():
	velocity = Vector2.ZERO
	get_tree().change_scene_to_file("res://main_menu/cena_game_over.tscn")

# ------------------ ANIMAÇÃO ----------------------

func _update_animation():
	var v = velocity
	
	if v.length() == 0:
		match facing_dir:
			Vector2.RIGHT: anim.play("IDLE_RIGHT")
			Vector2.LEFT: anim.play("IDLE_LEFT")
			Vector2.DOWN: anim.play("IDLE_DOWN")
			Vector2.UP: anim.play("IDLE_UP")
		return

	if abs(v.x) > abs(v.y):
		if v.x > 0:
			anim.play("RIGHT")
			facing_dir = Vector2.RIGHT
		else:
			anim.play("LEFT")
			facing_dir = Vector2.LEFT
	else:
		if v.y > 0:
			anim.play("DOWN")
			facing_dir = Vector2.DOWN
		else:
			anim.play("UP")
			facing_dir = Vector2.UP
