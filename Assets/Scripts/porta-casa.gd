extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem encostou na porta foi o Player
	# IMPORTANTE: Verifique se o nó do seu personagem na cena se chama exatamente "Player"
	if body.name == "Player":
		print("Saindo de casa...")
		
		# Troca para a cena do mapa principal
		get_tree().change_scene_to_file("res://mapa.tscn")
