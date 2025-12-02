extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Mapa/biblioteca.tscn")


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
