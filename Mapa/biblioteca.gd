extends Node2D

@onready var armarioFalso = $"Chões/AmárioFalso"

func _on_descobre_armario_falso_body_entered(body: Node2D) -> void:
	armarioFalso.hide()
