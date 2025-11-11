extends PanelContainer

@onready var label = $RichTextLabel

var full_text = ""
var current_index = 0
var typing_speed = 0.02 # segundos por caractere

func _ready():
	# Exemplo de uso
	await get_tree().create_timer(3).timeout
	show_text("Você é um estudante, mas também é um membro ativista da resistência. Como todos nós, você tem obrigações a cumprir e objetivos claros que precisam ser alcançados. Lembre-se, o tempo para agir durante o dia é limitado. Cada minuto conta antes que eles percebam nossa movimentação.\nTome cuidado.")
	
func show_text(text: String):
	full_text = text
	current_index = 0
	label.text = ""
	_type_next_character()

func _type_next_character():
	if current_index < full_text.length():
		label.text += full_text[current_index]
		current_index += 1
		# Atualiza a rolagem para o fim, caso precise
		label.scroll_to_line(label.get_line_count())
		# Chama novamente depois do delay
		await get_tree().create_timer(typing_speed).timeout
		_type_next_character()
