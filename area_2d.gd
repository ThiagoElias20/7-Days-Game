extends Area2D

# Defina aqui o caminho da cena de "Fim do Dia" ou "Resumo"
# Pode ser uma cutscene final ou o menu de pontuação
const CENA_FIM_DIA = "res://ui/resumo_dia_1.tscn" 

func _ready():
	# A porta começa TRANCADA (sem monitorar colisão)
	monitoring = false
	
	# Fica ouvindo o TaskManager
	TaskManager.casa_liberada.connect(_on_casa_liberada)
	
	# Conecta a colisão (se você não conectou via editor)
	body_entered.connect(_on_body_entered)

# Quando o Mural for feito, essa função roda
func _on_casa_liberada():
	print("Objetivos cumpridos. Porta destrancada!")
	monitoring = true # Agora a porta funciona!

func _on_body_entered(body):
	if body.name == "Player":
		print("Dia 1 Finalizado!")
		# Transição para o fim do dia (conforme roteiro "4. O Retorno")
		call_deferred("_finalizar_dia")

func _finalizar_dia():
	# Aqui você carrega a próxima cena (pode ser uma tela preta com texto, etc.)
	get_tree().change_scene_to_file(CENA_FIM_DIA)
