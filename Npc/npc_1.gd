extends CharacterBody2D

@export var speed: float = 150.0
@export var ficar_parado: bool = false

# --- NOVO: Caixa de seleção para a direção inicial ---
@export_enum("LEFT", "RIGHT", "UP", "DOWN") var direcao_inicial: String = "DOWN"

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
	if ficar_parado:
		# --- TRUQUE PARA FICAR PARADO VIRADO ---
		# 1. Toca a animação da direção escolhida (ex: "LEFT")
		animated_sprite.play(direcao_inicial)
		
		# 2. Para a animação no frame 0 ou 1
		# (Isso faz ele parecer que está parado virado, sem ficar "andando no lugar")
		animated_sprite.stop()
		animated_sprite.frame = 1 # Ajuste para 0 ou 1 dependendo de qual frame fica melhor parado
		
	else:
		# Comportamento normal de patrulha
		pick_new_direction()

func _physics_process(delta):
	# Se estiver parado, não faz mais nada (já configuramos no _ready)
	if ficar_parado:
		return 

	# Lógica de andar (só acontece se ficar_parado for false)
	velocity = current_direction * speed
	move_and_slide()
	_update_animation()

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

func _on_timer_timeout():
	if not ficar_parado:
		pick_new_direction()
