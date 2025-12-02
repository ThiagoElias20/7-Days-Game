extends Node

# --- Constantes ---
const FLYER_TARGET: int = 5
const FLYER_TASK_BASE_NAME: String = "Distribuir panfletos"
const MURAL_TASK_NAME: String = "Colocar panfleto na estatua"
const MURAL_TASK_COMPLETED: String = MURAL_TASK_NAME + " (feito)"

# Sinais
signal tasks_updated(new_tasks_list)
signal flyer_count_changed(new_count)
signal mural_unlocked 
signal casa_liberada # <--- NOVO: Avisa a porta que ela pode abrir

var flyers_placed: int = 0
var current_tasks: Array[String] = []

func _ready() -> void:
	# 1. Inicializa APENAS a missão principal
	var initial_flyer_task = create_flyer_task_string(flyers_placed)
	current_tasks.append(initial_flyer_task)
	
	await get_tree().process_frame
	tasks_updated.emit(current_tasks)

func create_flyer_task_string(count: int) -> String:
	var display_count = min(count, FLYER_TARGET)
	return "%s (%d/%d)" % [FLYER_TASK_BASE_NAME, display_count, FLYER_TARGET]

func place_flyer():
	# Incrementa contagem (Limite é 6: 5 normais + 1 mural)
	if flyers_placed < FLYER_TARGET + 1:
		flyers_placed += 1
		
		# CASO A: Panfletos Normais (1 até 5)
		if flyers_placed <= FLYER_TARGET:
			# Atualiza o texto da missão principal
			for i in range(current_tasks.size()):
				if current_tasks[i].begins_with(FLYER_TASK_BASE_NAME):
					current_tasks[i] = create_flyer_task_string(flyers_placed)
					break
			
			# GATILHO: Se acabou de completar 5/5, libera o Mural
			if flyers_placed == FLYER_TARGET:
				print("Missão principal completa! Liberando Mural...")
				current_tasks.append(MURAL_TASK_NAME)
				mural_unlocked.emit()
				GlobalVar.is_day_completed = true
		
		# CASO B: Panfleto do Mural (O 6º panfleto)
		elif flyers_placed == FLYER_TARGET + 1:
			# 1. Marca a tarefa do mural como feita
			for i in range(current_tasks.size()):
				if current_tasks[i] == MURAL_TASK_NAME:
					current_tasks[i] = MURAL_TASK_COMPLETED
					break
			
			GlobalVar.is_secondary_task_completed = true
			
			# 2. ADICIONA A NOVA TAREFA: VOLTAR PARA CASA
			current_tasks.append("Voltar para casa")
			
			# 3. AVISA A PORTA
			casa_liberada.emit()


# Função para definir uma tarefa simples (texto direto, sem contar 0/5)
func set_simple_task(task_text: String):
	current_tasks.clear()
	current_tasks.append(task_text)
	tasks_updated.emit(current_tasks)
	# Atualiza o HUD
	tasks_updated.emit(current_tasks)
	flyer_count_changed.emit(flyers_placed)
