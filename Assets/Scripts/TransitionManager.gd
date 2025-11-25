# TransitionManager.gd (Configure como Autoload)
extends Node

const TRANSITION_SCREEN_PATH = "res://TransitionScreen.tscn"
var transition_screen_instance: CanvasLayer = null

func start_transition_to_day_2() -> void:
	# 1. Carrega e instancia a cena de transição
	var transition_scene = load(TRANSITION_SCREEN_PATH)
	if not transition_scene:
		print("ERRO: Cena de Transição não encontrada em ", TRANSITION_SCREEN_PATH)
		return
		
	transition_screen_instance = transition_scene.instantiate()
	
	# Adiciona a tela de transição à árvore principal (garantindo que fique no topo)
	get_tree().get_root().add_child(transition_screen_instance)
	
	# 2. Chama a função de início da transição
	if transition_screen_instance.has_method("start_transition"):
		transition_screen_instance.start_transition()
