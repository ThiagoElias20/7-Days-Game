extends Node

# --- CONFIGURAÇÃO DO TEMPO ---
# 1 hora no jogo = 60 segundos reais (1 minuto)
const GAME_HOUR_IN_REAL_SECONDS = 10.0

# O sinal que o HUD e o TaskManager vão ouvir
signal time_updated(hour, minute)

# Dia e hora inicial (baseado na lógica que você tinha)
var dia: int = 1
var start_hour: int
var start_minute: int = 0

var elapsed_time: float = 0.0
var current_hour: int
var current_minute: int

func _ready() -> void:
	match dia:
		1: start_hour = 4
		2: start_hour = 19
		3: start_hour = 10
		4: start_hour = 15
		5: start_hour = 9
		6: start_hour = 23
		_: start_hour = 0
	
	current_hour = start_hour
	current_minute = start_minute
	set_process(true)
	
	# Emite o sinal inicial (atrasado por um frame para garantir que todos estejam prontos)
	await get_tree().process_frame
	time_updated.emit(current_hour, current_minute)

func _process(delta: float) -> void:
	elapsed_time += delta
	var game_hours_passed = elapsed_time / GAME_HOUR_IN_REAL_SECONDS
	var total_game_minutes_passed = game_hours_passed * 60.0
	
	var new_total_minutes_from_start = (start_hour * 60.0) + start_minute + total_game_minutes_passed
	var new_hour = fmod(new_total_minutes_from_start / 60.0, 24.0)
	var new_minute = fmod(new_total_minutes_from_start, 60.0)

	if int(new_minute) != current_minute:
		current_hour = int(new_hour)
		current_minute = int(new_minute)
		time_updated.emit(current_hour, current_minute)

# Funções que outros podem chamar
func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

func get_current_hour() -> int:
	return current_hour
