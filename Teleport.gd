# Teleport.gd
extends Area2D

# Certifique-se de que o nó do jogador tem um grupo chamado "player"
# Se não, mude o nome do grupo abaixo ou use uma checagem diferente.

func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou é o jogador
	if body.is_in_group("player"):
		# Chama a função de transição do seu gerenciador global
		# Assumindo que você tem um Autoload (como GameManager ou TransitionManager)
		TransitionManager.start_transition_to_day_2()
		
		# Desabilita o teleporte para evitar múltiplos triggers
		set_monitoring(false)
