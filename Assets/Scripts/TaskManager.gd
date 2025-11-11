extends Node

signal tasks_updated(new_tasks_list)

# --- CONFIGURAÇÃO DAS TAREFAS (Mantido) ---
# O dicionário ainda é útil para sabermos quais tarefas existem
var all_tasks = {
	8: "Pegar os panfletos na gráfica",
	9: "Distribuir panfletos na Praça da Sé",
	12: "Encontrar com o contato no café",
	18: "Voltar para casa antes do toque de recolher"
}
# --------------------------------

var current_tasks: Array[String] = []

func _ready() -> void:
	# --- ALTERAÇÃO PARA PROTÓTIPO ---
	# Em vez de esperar o relógio, vamos adicionar todas as tarefas IMEDIATAMENTE.
	
	for task_description in all_tasks.values():
		current_tasks.append(task_description)

	# Espera um frame para garantir que o HUD.gd já carregou e está "ouvindo"
	await get_tree().process_frame
	
	# Emite o sinal UMA VEZ com a lista completa
	tasks_updated.emit(current_tasks)

	# --- REMOVIDO ---
	# Não vamos mais nos conectar ao relógio para este protótipo.
	# TimeManager.time_updated.connect(_on_time_updated)


# --- REMOVIDO ---
# Esta função não é mais necessária, já que não estamos ouvindo o relógio
# func _on_time_updated(hour: int, minute: int) -> void:
#	 ... (código antigo removido) ...


# Esta função ainda é útil se você quiser testar completar tarefas
func complete_task(task_name: String) -> void:
	if current_tasks.has(task_name):
		current_tasks.erase(task_name)
		tasks_updated.emit(current_tasks) # Avisa o HUD que a lista mudou
