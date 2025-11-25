# TransitionScreen.gd
extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var text_label: Label = $TextLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# A cena de destino após a transição (Mude para o caminho da sua próxima cena!)
const NEXT_SCENE_PATH = "./interior1.tscn"

# Função principal chamada pelo Autoload (Gerenciador Global)
func start_transition() -> void:
	text_label.text = "DIA 2"
	# Certifique-se de ter uma animação chamada "fade_out" no AnimationPlayer
	anim_player.play("fade_out")
	await anim_player.animation_finished
	
	# 1. Troca o texto enquanto a tela ainda está preta
	text_label.text = "CARREGANDO..."
	
	# 2. Muda para a próxima cena (que é a parte mais importante)
	change_scene()


func change_scene() -> void:
	# Garante que a transição ocorra no próximo frame
	await get_tree().process_frame
	
	# Esta é a forma recomendada de mudar de cena no Godot
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)
	if error != OK:
		print("ERRO ao carregar a cena: ", error)
	
	# Opcional: Se a tela de transição for Autoload, você pode removê-la aqui.
	# Se for adicionada temporariamente (como sugerido abaixo), não precisa.
