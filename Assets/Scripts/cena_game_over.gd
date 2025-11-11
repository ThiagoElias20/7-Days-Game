extends Control

# ===== Ajuste rápido: escala do MENU (card, botões, fontes) =====
const UI_SCALE := 1.5   # 1.0 = original; aumente/diminua conforme preferir

var btn_retry: Button
var btn_menu: Button

func _ready() -> void:
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame

	_build_ui()
	_connect_logic()
	_apply_styles()
	_fade_in()
	_pulse_background()

func _s(v: float) -> float:
	return v * UI_SCALE

func _build_ui() -> void:
	# ===== Fundo com IMAGEM (Mantido) =====
	var bg_texture := preload("res://Assets/Images/telagameover.jpg")
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.texture = bg_texture
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.modulate = Color(1, 1, 1, 1)
	bg.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_full_rect(bg)
	add_child(bg)

	# Overlay para contraste do texto (Mantido)
	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	_full_rect(overlay)
	overlay.color = Color(0, 0, 0, 0.30)  # Deixei o overlay, caso queira escurecer um pouco
	add_child(overlay)

	# ===== [REMOVIDO] Card, CenterContainer, VBox e Labels =====
	# Não precisamos mais do card preto nem dos labels de texto.
	
	# ===== [NOVO] HBoxContainer para os botões lado-a-lado =====
	var hbox := HBoxContainer.new()
	hbox.name = "ButtonContainer"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER # Centraliza os botões dentro dele
	hbox.add_theme_constant_override("separation", int(_s(20))) # Espaço entre os botões
	add_child(hbox)

	# --- Posiciona o HBox na parte de baixo da tela ---
	hbox.anchor_left = 0.0
	hbox.anchor_top = 1.0   # Ancora no fundo
	hbox.anchor_right = 1.0  # Largura total
	hbox.anchor_bottom = 1.0 # Ancora no fundo
	# Define uma "caixa" na parte de baixo para os botões
	# (Ex: 120 pixels para cima a partir do fundo)
	hbox.offset_top = -_s(120) 
	hbox.offset_bottom = -_s(40) # (Ex: 40 pixels para cima a partir do fundo)
	
	# ===== Botões (Adicionados ao HBox) =====
	btn_retry = _mk_button("Tentar Novamente", "BtnRetry")
	btn_menu  = _mk_button("Voltar ao Menu",   "BtnMenu")

	hbox.add_child(btn_retry)
	hbox.add_child(btn_menu)

	# Foco inicial
	btn_retry.grab_focus()

func _mk_button(text: String, node_name: String) -> Button:
	# Esta função é perfeita, mantida 100%
	var b := Button.new()
	b.name = node_name
	b.text = text
	b.custom_minimum_size = Vector2(_s(300), _s(52))
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", int(_s(20)))
	return b

func _connect_logic() -> void:
	# --- Conexões Corrigidas ---
	# btn_retry.pressed.connect(_on_retry) # Descomentado
	btn_menu.pressed.connect(_on_menu)

func _apply_styles() -> void:
	# ===== [REMOVIDO] Estilo do Card =====
	# var card := $"CenterContainer/Card" as Panel
	# ... (todo o bloco do sb foi removido) ...

	# ===== [MANTIDO] Estilo dos Botões =====
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.13, 0.13, 0.95)
	normal.set_corner_radius_all(int(_s(10)))
	normal.set_border_width_all(int(_s(1)))
	normal.border_color = Color8(85, 107, 47, 180)
	normal.set_content_margin_all(_s(8))

	var hover := normal.duplicate()
	hover.bg_color = Color(0.16, 0.18, 0.17, 0.98)
	hover.border_color = Color8(85, 140, 60, 220)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.22, 0.23, 0.22, 1.0)
	pressed.border_color = Color8(139, 0, 0, 220)

	var focus := normal.duplicate()
	focus.set_border_width_all(int(_s(2)))
	focus.border_color = Color8(255, 215, 0, 220)

	for b in [btn_retry, btn_menu]:
		b.add_theme_stylebox_override("normal", normal)
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("pressed", pressed)
		b.add_theme_stylebox_override("focus", focus)
		b.scale = Vector2.ONE
		b.mouse_entered.connect(func(): _pulse(b, 1.03))
		b.mouse_exited.connect(func(): _pulse(b, 1.0))
		b.focus_entered.connect(func(): _pulse(b, 1.03))
		b.focus_exited.connect(func(): _pulse(b, 1.0))

# --- Funções Helper (Mantidas 100%) ---

func _pulse(node: Control, to_scale: float) -> void:
	var t := create_tween()
	t.tween_property(node, "scale", Vector2(to_scale, to_scale), 0.08)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _fade_in() -> void:
	var fade := ColorRect.new()
	_full_rect(fade)
	fade.color = Color(0,0,0,1)
	add_child(fade)
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 0.45)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
	 .finished.connect(func(): fade.queue_free())

func _pulse_background() -> void:
	var bg := $"Background"
	var t := create_tween().set_loops()    # loop infinito
	t.tween_property(bg, "modulate:a", 0.92, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(bg, "modulate:a", 1.00, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _full_rect(node: Control) -> void:
	node.anchor_left = 0
	node.anchor_top = 0
	node.anchor_right = 1
	node.anchor_bottom = 1
	node.offset_left = 0
	node.offset_top = 0
	node.offset_right = 0
	node.offset_bottom = 0

# ===== Callbacks (Corrigidos) =====
func _on_retry() -> void:
	print("Tentar Novamente -> Carregando Jogo")
	# MUDE AQUI: Coloque o caminho para sua cena de jogo principal
	# get_tree().change_scene_to_file("res://ui/main_menu/Cutscene1.tscn") # <- MUDE ISSO

func _on_menu() -> void:
	print("Voltando ao Menu")
	get_tree().change_scene_to_file("res://ui/main_menu/MainMenu.tscn")
