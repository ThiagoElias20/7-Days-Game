extends CanvasLayer

@onready var clock_label: Label = $ClockLabel
@onready var task_list: VBoxContainer = $TaskContainer/TaskList

# --- CORREÇÃO 1: Já iniciamos com os valores do DIA 1 ---
# Assim, se o código não conseguir ler o nome da cena, o Dia 1 funciona garantido.
var target_amount: int = 5 
var target_task_name: String = "Distribuir panfletos"

func _ready() -> void:
	# Configura a UI para ignorar cliques do mouse (importante para não travar o jogo)
	_configurar_mouse_filter()
	
	await get_tree().process_frame
	
	# Tenta identificar se precisa mudar as regras (para Dia 2, 3, etc)
	_configurar_regras_do_nivel()
	
	if not TimeManager.is_connected("time_updated", _on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)
	
	if not TaskManager.is_connected("tasks_updated", _on_tasks_updated):
		TaskManager.tasks_updated.connect(_on_tasks_updated)
	
	_on_time_updated(TimeManager.get_current_hour(), TimeManager.current_minute)
	_on_tasks_updated(TaskManager.current_tasks)

func _configurar_mouse_filter() -> void:
	# Garante que o container da lista não bloqueie cliques no mundo do jogo
	if task_list:
		task_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Se o pai da lista (TaskContainer) for um Control, também deve ignorar
	if task_list.get_parent() is Control:
		task_list.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE

func _configurar_regras_do_nivel() -> void:
	var nome_cena = get_tree().current_scene.name
	print("HUD Detectou Cena: ", nome_cena) # Olhe isso no Output se der erro
	
	match nome_cena:
		"Dia2": 
			target_task_name = "Descriptografar carta"
			target_amount = 1
		"Dia3":
			target_task_name = "Entregar jornal"
			target_amount = 3
		# --- CORREÇÃO 2: O Dia 1 agora é o Default ---
		# Se for "Dia1" OU qualquer nome estranho (ex: "Main", "World"), usa a regra do panfleto
		_: 
			target_task_name = "Distribuir panfletos"
			target_amount = 5
			print("Usando regras do Dia 1 (Padrão)")

func _on_time_updated(hour: int, minute: int) -> void:
	if clock_label:
		clock_label.text = "%02d:%02d" % [hour, minute]

func _on_tasks_updated(tasks: Array[String]) -> void:
	if task_list:
		for child in task_list.get_children():
			child.queue_free()
			
		for task_text in tasks:
			var new_label = RichTextLabel.new()
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			new_label.fit_content = true
			
			# Habilita o BBCode para as cores funcionarem
			new_label.bbcode_enabled = true 
			
			var formatted_text = "- " + task_text
			
			# Verifica se é a tarefa alvo
			if task_text.begins_with(target_task_name):
				var completion_string = "(%d/%d)" % [target_amount, target_amount]
				
				# Se terminou (ex: 5/5), pinta de verde e risca
				if task_text.ends_with(completion_string):
					formatted_text = "- [color=lime][s]%s[/s][/color]" % task_text
			
			# --- IMPORTANTE: Usar append_text ou parse_bbcode para RichTextLabel ---
			new_label.text = formatted_text 
			
			task_list.add_child(new_label)
