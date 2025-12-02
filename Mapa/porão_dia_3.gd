extends Node2D

@onready var npc_m = $NPC_2 # O Traidor (Area2D)
@onready var papel_chao = $papel # O Papel (Area2D)
@onready var porta_saida = $Area2D # A Saida (Area2D)

var papel_lido : bool = false

func _ready():
	# Missão Inicial
	TaskManager.set_simple_task("Fale com o 'M'")
	
	# Começa tudo travado
	porta_saida.monitoring = false 
	papel_chao.visible = false
	papel_chao.monitoring = false # Desliga colisão do papel invisível

# --- PASSO 3: FINAIS ---
func _confrontar_m():
	print("Você confrontou M.")
	GlobalVar.traidor_confrontado = true
	GlobalVar.is_secondary_task_completed = true
	GlobalVar.score += GlobalVar.PontuacoesSecundarias[2]
	_encerrar_dia()

func _on_porta_saida_body_entered(body):
	if body.name == "Player" and papel_lido:
		print("Você fugiu.")
		GlobalVar.traidor_confrontado = false
		_encerrar_dia()

func _encerrar_dia():
	GlobalVar.dia = 3
	get_tree().change_scene_to_file("res://ui/resumo_dia.tscn")

func _on_npc_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# CENA 1: M derruba o papel
		if not papel_chao.visible:
			print("M: 'Hã? Ah, oi. Estou... (Ele derruba algo)'")
			
			# O Papel aparece
			papel_chao.visible = true
			papel_chao.monitoring = true
			
			TaskManager.set_simple_task("Veja o que caiu no chão")
		
		# CENA 3: Confronto (só funciona se já leu o papel)
		elif papel_lido:
			_confrontar_m()


func _on_papel_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		papel_lido = true
		print("VOCÊ LEU: É uma lista de nomes para a polícia!")
		
		# Pontuação e Progresso
		GlobalVar.score += GlobalVar.PontuacoesPrimarias[2]
		GlobalVar.is_day_completed = true
		
		# O papel some (foi pego)
		papel_chao.visible = false
		papel_chao.monitoring = false
		
		# Libera a saída e atualiza missão
		porta_saida.monitoring = true
		TaskManager.set_simple_task("TRAIDOR! Confronte M ou Fuja!")
