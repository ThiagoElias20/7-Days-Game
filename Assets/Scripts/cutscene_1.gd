extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

const PROXIMA_CENA = "res://Mapa/player_house.tscn"

func _ready() -> void:
	anim_player.animation_finished.connect(_ao_terminar_animacao)
	anim_player.play("AnimacaoInicio")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_gerenciar_clique()

func _gerenciar_clique() -> void:
	# Ao clicar, aceleramos a animação para o texto aparecer instantaneamente
	anim_player.speed_scale = 50.0 

# --- NOVA FUNÇÃO ---
# Vamos chamar essa função na LINHA DO TEMPO no início de cada frase
func restaurar_velocidade() -> void:
	anim_player.speed_scale = 1.0

func _ao_terminar_animacao(anim_name: String) -> void:
	if anim_name == "AnimacaoInicio":
		get_tree().change_scene_to_file(PROXIMA_CENA)
