extends Area2D

# Exporte a variável para poder selecionar a cena do porão direto no Inspetor
@export var cena_do_porao: String = "res://Mapa/porão.tscn"

func _ready() -> void:
	# Conecta o sinal via código (ou você pode fazer pela aba "Nó" do editor)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# É importante verificar se quem entrou foi o Jogador
	# Se o seu jogador se chama "Player" ou está num grupo "player":
	if body.name == "Player" or body.is_in_group("player"):
		print("Entrando no porão...")
		call_deferred("mudar_cena")

func mudar_cena() -> void:
	# Troca para a cena do porão
	get_tree().change_scene_to_file(cena_do_porao)
