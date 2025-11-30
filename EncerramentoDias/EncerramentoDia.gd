extends Control

var texto := ""

func _ready() -> void:
	var dia_idx := GlobalVar.dia - 1

	if dia_idx < 0 or dia_idx >= 3:
		return

	var primary = GlobalVar.PontuacoesPrimarias[dia_idx]
	var secondary = 0.0

	if GlobalVar.is_secondary_task_completed:
		secondary = GlobalVar.PontuacoesSecundarias[dia_idx]

	var time_bonus = calcular_bonus_tempo(GlobalVar.time_elapsed_day)

	var total = primary + secondary + time_bonus

	texto = "Tempo Decorrido: %s\nPontuação Tasks Primarias: %s\nPontuação Tasks Secundárias: %s\nBônus por Tempo: %s\nPontuacaoTotal: %s" % [
		GlobalVar.time_elapsed_day,
		primary,
		secondary,
		time_bonus,
		total
	]
	
	GlobalVar.total_time += GlobalVar.time_elapsed_day
	GlobalVar.score += total

	match GlobalVar.dia:
		1:
			$Dia1.visible = true
		2:
			$Dia2.visible = true
		3:
			$Dia3.visible = true

	$Stats.text = texto


func calcular_bonus_tempo(segundos: int) -> float:
	var bonus := 100 - segundos
	if bonus < 0:
		bonus = 0
	return bonus
