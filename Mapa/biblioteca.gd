extends Node2D

@onready var armarioFalso = $"Chões/ArmárioFalso"
@onready var colisorArmario = $"Descobre Armario Falso/Colisor Armário"


func _on_descobre_armario_falso_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		armarioFalso.hide()
		colisorArmario.disabled = true


func _on_entra_na_portinha_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		null
