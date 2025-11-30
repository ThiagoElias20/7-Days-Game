extends Node2D

var cena_pai = get_parent()


func _on_area_2d_body_entered(body: Node2D) -> void:
		# IMPORTANTE: Verifique se o nó do seu personagem na cena se chama exatamente "Player"
	if body.name == "Player" and GlobalVar.is_day_completed == true:
		# Troca para a cena do mapa principal
		get_tree().change_scene_to_file("res://EncerramentoDias/EncerramentoDia.tscn")
		
	if body.name == "Player" and GlobalVar.is_day_completed == false:
		# Troca para a cena do mapa principal
		get_tree().change_scene_to_file("res://Mapa/Player_House.tscn")
		
		
