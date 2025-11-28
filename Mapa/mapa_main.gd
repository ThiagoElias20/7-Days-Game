extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
		# IMPORTANTE: Verifique se o nó do seu personagem na cena se chama exatamente "Player"
	if body.name == "Player":		
		# Troca para a cena do mapa principal
		get_tree().change_scene_to_file("res://Mapa/Player_House.tscn")
