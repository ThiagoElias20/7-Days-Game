extends Node

# --- Constantes para o objetivo ---
const FLYER_TARGET: int = 5
const FLYER_TASK_BASE_NAME: String = "Distribuir panfletos" # A parte fixa do texto
# ---------------------------------

# --- Constantes para a Tarefa Secundária ---
const MURAL_TASK_KEY: int = 9
const MURAL_TASK_NAME: String = "Colocar panfleto no mural"
const MURAL_TASK_COMPLETED: String = MURAL_TASK_NAME + " (feito)"
# -------------------------------------------


signal tasks_updated(new_tasks_list)
signal flyer_count_changed(new_count)

var flyers_placed: int = 0
var all_tasks = {
	8: FLYER_TASK_BASE_NAME,
	9: MURAL_TASK_NAME
}

var current_tasks: Array[String] = []

func _ready() -> void:
	# Inicializa a lista de tarefas, gerando a string de panfletos
	for key in all_tasks:
		var task_name = all_tasks[key]
		
		if key == 8: # A chave da tarefa dinâmica (Panfletos)
			var initial_flyer_task = create_flyer_task_string(flyers_placed)
			current_tasks.append(initial_flyer_task)
		else:
			# Adiciona a task do Mural não concluída
			current_tasks.append(task_name)
	
	await get_tree().process_frame
	tasks_updated.emit(current_tasks)


# Função auxiliar que cria a string formatada da missão de panfletos
func create_flyer_task_string(count: int) -> String:
	# Ex: "Distribuir panfletos (3/5)"
	# A contagem NUNCA deve ser maior que FLYER_TARGET na string.
	var display_count = min(count, FLYER_TARGET)
	return "%s (%d/%d)" % [FLYER_TASK_BASE_NAME, display_count, FLYER_TARGET]


func place_flyer():
	# 1. Incrementa a contagem de panfletos, APENAS ATÉ 6 (o sexto panfleto)
	# O incremento só ocorre se flyers_placed for menor que 6.
	if flyers_placed < FLYER_TARGET + 1: # TARGET + 1 é 6
		flyers_placed += 1
		
		# 2. Lógica principal: Panfletos de 1 a 5
		if flyers_placed <= FLYER_TARGET:
			# Apenas atualiza a string de contagem (0/5, 1/5, ..., 5/5)
			var new_task_string = create_flyer_task_string(flyers_placed)
			
			# Encontra a tarefa de panfleto e atualiza
			for i in range(current_tasks.size()):
				if current_tasks[i].begins_with(FLYER_TASK_BASE_NAME):
					current_tasks[i] = new_task_string
					break
		
		# 3. Lógica do Panfleto Extra: O sexto panfleto (flyers_placed == 6)
		if flyers_placed == FLYER_TARGET + 1:
			# Muda a tarefa do Mural para (feito)
			for i in range(current_tasks.size()):
				# Busca pela string original da tarefa do mural
				if current_tasks[i] == MURAL_TASK_NAME:
					current_tasks[i] = MURAL_TASK_COMPLETED
					break

	# 4. Emite o sinal para o HUD (mesmo se flyers_placed for 6)
	tasks_updated.emit(current_tasks)
	flyer_count_changed.emit(flyers_placed)
