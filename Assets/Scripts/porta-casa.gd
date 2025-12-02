extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem encostou na porta foi o Player
	# IMPORTANTE: Verifique se o nó do seu personagem na cena se chama exatamente "Player"
	if body.name == "Player":
		print("Saindo de casa..." + str(GlobalVar.dia))
		
		get_tree().change_scene_to_file("res://main_menu/Loading.tscn")
		GlobalVar.proxima_cena = "res://Gameplay/Dia" + str(GlobalVar.dia) + ".tscn"
		
		
