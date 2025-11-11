# npc.gd
extends CharacterBody2D

@export var speed: float = 150.0  # Um pouco mais lento que o jogador

var current_direction = Vector2.ZERO

var direction_options = [
	Vector2.LEFT,    # (-1, 0)
	Vector2.RIGHT,   # (1, 0)
	Vector2.UP,      # (0, -1)
	Vector2.DOWN,    # (0, 1)
	Vector2.ZERO     # (0, 0) - Ficar parado
]

func _ready():
	pick_new_direction()

func _physics_process(delta):
	velocity = current_direction * speed
	move_and_slide()

func pick_new_direction():
	current_direction = direction_options.pick_random()
