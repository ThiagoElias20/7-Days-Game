# npc.gd
extends CharacterBody2D

@export var speed: float = 150.0

var current_direction = Vector2.ZERO

var direction_options = [
	Vector2.LEFT,
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.DOWN,
	Vector2.ZERO
]

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	pick_new_direction()

func _physics_process(delta):
	velocity = current_direction * speed
	_update_animation()
	move_and_slide()

func pick_new_direction():
	current_direction = direction_options.pick_random()

func _update_animation():
	if current_direction == Vector2.RIGHT:
		animated_sprite.play("RIGHT")
	elif current_direction == Vector2.LEFT:
		animated_sprite.play("LEFT")
	elif current_direction == Vector2.UP:
		animated_sprite.play("UP")
	elif current_direction == Vector2.DOWN:
		animated_sprite.play("DOWN")
	else:
		animated_sprite.play("IDLE")
