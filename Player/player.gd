extends CharacterBody2D

@export var speed: float = 300.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Estados possíveis: "UP", "DOWN", "LEFT", "RIGHT"
var last_anim_state: String = "DOWN"

func _physics_process(delta):
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = direction * speed if direction != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

	_update_animation(direction)


func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# Parado → mantém última direção
		match last_anim_state:
			"DOWN": anim.play("IDLE DOWN")
			"UP": anim.play("IDLE UP")
			"LEFT": anim.play("IDLE LEFT")
			"RIGHT": anim.play("IDLE RIGHT")
		return

	# Movimento ativo
	if abs(direction.y) > abs(direction.x):
		if direction.y > 0:
			anim.play("WALK DOWN")
			last_anim_state = "DOWN"
		else:
			anim.play("WALK UP")
			last_anim_state = "UP"
	else:
		if direction.x > 0:
			anim.play("WALK RIGHT")
			last_anim_state = "RIGHT"
		else:
			anim.play("WALK LEFT")
			last_anim_state = "LEFT"
