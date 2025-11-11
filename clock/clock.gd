extends Node2D

# SINAL (NOVO): Avisa o TaskManager e o HUD quando o minuto muda
signal time_updated(hour, minute)

# --- Nós (do script original) ---
@onready var pivot_hours: Marker2D = $"Pivot Hours"
@onready var pivot_minutes: Marker2D = $"Pivot Minutes"

# --- Variáveis de Exportação (do script original) ---
@export var dia: int = 2
@export var start_hour: int
@export var start_minute: int = 0

# --- Variáveis de Estado (do script original) ---
var elapsed_time: float = 0.0
var minutes_angle: float
var hours_angle: float

# --- Constante de Tempo (Baseada na lógica do seu colega) ---
# 1 hora no jogo = 60 segundos reais (1 minuto)
const GAME_HOUR_IN_REAL_SECONDS = 60.0

# --- Variáveis de Lógica de Tempo (NOVAS) ---
var current_hour: int
var current_minute: int

func _ready() -> void:
	# Lógica original para definir a hora inicial baseada no dia
	match dia:
		1:
			start_hour = 4
		2:
			start_hour = 19
		3:
			start_hour = 10
		4:
			start_hour = 15
		5:
			start_hour = 9
		6:
			start_hour = 23
		_:
			start_hour = 0
			
	# Lógica visual original para posicionar os ponteiros
	minutes_angle = start_minute * 6.0
	hours_angle = (start_hour % 12) * 30.0 + (start_minute / 60.0) * 30.0
	pivot_minutes.rotation_degrees = minutes_angle
	pivot_hours.rotation_degrees = hours_angle
	
	# --- NOVO: Inicializa a lógica de tempo ---
	current_hour = start_hour
	current_minute = start_minute
	# Emite o sinal inicial para o HUD já começar com a hora certa
	time_updated.emit(current_hour, current_minute)


func _process(delta: float) -> void:
	# --- Lógica Visual Original dos Ponteiros ---
	# Ponteiro de minutos → gira 360° a cada 60 segundos reais
	minutes_angle += 360.0 / 60.0 * delta  # 6° por segundo
	# Ponteiro de horas → gira 360° a cada 12 * 60 segundos (12 minutos reais)
	hours_angle += 360.0 / 60.0 / 12.0 * delta  # 0.5° por segundo
	
	pivot_minutes.rotation_degrees = minutes_angle
	pivot_hours.rotation_degrees = hours_angle
	
	# --- Lógica de Tempo Original ---
	elapsed_time = elapsed_time + delta
	
	
	# --- NOVO: Lógica de Cálculo e Sincronização ---
	
	# 1. Calcula quantas "horas de jogo" se passaram
	var game_hours_passed = elapsed_time / GAME_HOUR_IN_REAL_SECONDS
	
	# 2. Calcula o total de "minutos de jogo" desde o início
	var total_game_minutes_passed = game_hours_passed * 60.0
	
	# 3. Calcula a nova hora e minuto atuais
	var new_total_minutes_from_start = (start_hour * 60.0) + start_minute + total_game_minutes_passed
	var new_hour = fmod(new_total_minutes_from_start / 60.0, 24.0)
	var new_minute = fmod(new_total_minutes_from_start, 60.0)

	# 4. Se o minuto MUDOU, avise todo mundo!
	if int(new_minute) != current_minute:
		current_hour = int(new_hour)
		current_minute = int(new_minute)
		# Esta é a "sincronização" que você queria:
		time_updated.emit(current_hour, current_minute)

# --- NOVA FUNÇÃO HELPER ---
# O HUD vai usar isso para pegar o tempo se o sinal falhar
func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

# --- Função de Reset (Original + Adição) ---
func _reset_clock() -> void:
	# Lógica visual original
	minutes_angle = start_minute * 6.0
	hours_angle = (start_hour % 12) * 30.0 + (start_minute / 60.0) * 30.0
	pivot_minutes.rotation_degrees = minutes_angle
	pivot_hours.rotation_degrees = hours_angle
	elapsed_time = 0
	
	# --- NOVO: Reseta a lógica de tempo também ---
	current_hour = start_hour
	current_minute = start_minute
	time_updated.emit(current_hour, current_minute)
