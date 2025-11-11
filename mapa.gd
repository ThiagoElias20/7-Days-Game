extends Node2D # Ou qualquer que seja o seu nó raiz do mapa

# 1. Crie a variável para o gradiente (você preenche no Inspetor)
@export var day_night_gradient: Gradient

# 2. Crie a referência para o nó CanvasModulate
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

func _ready() -> void:
	# 3. Espere os Autoloads estarem prontos
	await get_tree().process_frame
	
	# 4. Conecte-se ao sinal do TimeManager
	if not TimeManager.is_connected("time_updated", _on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)
	
	# 5. Defina a cor inicial assim que o jogo começar
	_on_time_updated(TimeManager.get_current_hour(), TimeManager.current_minute)

# 6. Esta é a função que é chamada pelo TimeManager
func _on_time_updated(hour: int, minute: int) -> void:
	if canvas_modulate and day_night_gradient:
		
		# 7. Calcule a "fração" do dia (um valor de 0.0 a 1.0)
		var total_minutes = (hour * 60) + minute
		# 1440 minutos em um dia (24 * 60)
		var day_fraction = float(total_minutes) / 1440.0
		
		# 8. Use a fração para "provar" a cor no gradiente
		var new_color = day_night_gradient.sample(day_fraction)
		
		# 9. Aplique a cor ao CanvasModulate!
		canvas_modulate.color = new_color
