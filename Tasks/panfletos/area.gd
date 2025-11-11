extends Area2D

@onready var objetivo = get_node("../Objective");
@onready var panfleto = get_node("../Panfleto")

func _ready():
	panfleto.hide()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	panfleto.show()
	objetivo.hide()
