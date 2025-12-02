extends CanvasModulate

# O Gradiente ainda precisa ser arrastado no Inspector
@export var gradiente_dia_noite: Gradient

func _ready() -> void:
	# Como o TimeManager é global (AutoLoad), chamamos ele direto pelo nome dele.
	# O nome "TimeManager" deve ser EXATAMENTE como você escreveu em Project Settings -> Globals
	
	if TimeManager.has_signal("time_updated"):
		TimeManager.time_updated.connect(_atualizar_cor)
	else:
		print("ERRO: Não encontrei o sinal 'time_updated' no TimeManager Global.")

func _atualizar_cor(hora: int, minuto: int) -> void:
	if gradiente_dia_noite == null:
		return

	# O mesmo cálculo de antes
	var total_minutos_do_dia = 1440.0
	var minutos_atuais = (hora * 60.0) + minuto
	var ponto_do_dia = minutos_atuais / total_minutos_do_dia
	
	color = gradiente_dia_noite.sample(ponto_do_dia)
