extends CanvasLayer

@onready var clock_label: Label = $ClockLabel
@onready var task_list: VBoxContainer = $TaskContainer/TaskList

# Constante para saber qual é o objetivo de panfletos. Deve ser a mesma do TaskManager.
const FLYER_TARGET: int = 5
const FLYER_TASK_BASE_NAME: String = "Distribuir panfletos"

func _ready() -> void:
	# Espera um frame para garantir que os Autoloads estão prontos
	await get_tree().process_frame
	
	# 1. O HUD ouve o TimeManager (Global)
	if not TimeManager.is_connected("time_updated", _on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)
	
	# 2. O HUD ouve o TaskManager (Global)
	if not TaskManager.is_connected("tasks_updated", _on_tasks_updated):
		TaskManager.tasks_updated.connect(_on_tasks_updated)
	
	# Pega os valores iniciais
	_on_time_updated(TimeManager.get_current_hour(), TimeManager.current_minute)
	_on_tasks_updated(TaskManager.current_tasks)

# Esta função é chamada pelo TimeManager
func _on_time_updated(hour: int, minute: int) -> void:
	if clock_label:
		clock_label.text = "%02d:%02d" % [hour, minute]

# Esta função é chamada pelo TaskManager
func _on_tasks_updated(tasks: Array[String]) -> void:
	if task_list:
		# Remove todas as Labels antigas
		for child in task_list.get_children():
			child.queue_free()
			
		for task_text in tasks:
			# MUDE DE Label PARA RichTextLabel PARA USAR BBCODE
			var new_label = RichTextLabel.new()
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			# Garante que o RichTextLabel ajuste sua altura ao conteúdo
			new_label.fit_content = true 
			
			var formatted_text = "- " + task_text
			
			# 1. Checa se é a tarefa de panfleto
			if task_text.begins_with(FLYER_TASK_BASE_NAME):
				# 2. Define o formato de conclusão (ex: "(5/5)")
				var completion_string = "(%d/%d)" % [FLYER_TARGET, FLYER_TARGET]
				
				# 3. Checa se a tarefa está concluída
				if task_text.ends_with(completion_string):
					# Aplica o BBCode para Riscado ([s]) e Cor Verde ([color=green/lime])
					# O texto final será: - [color=lime][s]Distribuir panfletos (5/5)[/s][/color]
					formatted_text = "- [color=lime][s]%s[/s][/color]" % task_text
					
			# Define o texto. O RichTextLabel interpretará o BBCode.
			new_label.set_text(formatted_text)
			
			task_list.add_child(new_label)
