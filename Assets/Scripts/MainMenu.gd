extends Control

# ===== Ajuste rápido: escala do MENU (card, botões, fontes) =====
const UI_SCALE := 1.5   # 1.0 = original; aumente/diminua conforme preferir

var btn_play: Button
var btn_continue: Button
var btn_options: Button
var btn_credits: Button
var btn_quit: Button

func _ready() -> void:
	# Limpa filhos (idempotente)
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame

	_build_ui()
	_connect_logic()
	_apply_styles()
	_fade_in()
	_pulse_background()  # opcional: respiração sutil do fundo

# Helper para escalar valores de UI
func _s(v: float) -> float:
	return v * UI_SCALE

func _build_ui() -> void:
	# ===== Fundo com IMAGEM =====
	var bg_texture := preload("res://main_menu/background_init.jpeg")
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.texture = bg_texture
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED  # cobre a tela preservando proporção
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.modulate = Color(1, 1, 1, 1)    # opacidade do fundo (ajuste se quiser)
	bg.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST      # mantém pixel art nítido
	_full_rect(bg)
	add_child(bg)

	# Overlay para contraste do texto (escurece fundo levemente)
	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	_full_rect(overlay)
	overlay.color = Color(0, 0, 0, 0.30)  # ajuste 0.0–0.6 conforme contraste desejado
	add_child(overlay)

	# ===== Container central (full-rect) =====
	var center := CenterContainer.new()
	center.name = "CenterContainer"
	_full_rect(center)
	add_child(center)

	# ===== Card central (menu) =====
	var card := Panel.new()
	card.name = "Card"
	card.custom_minimum_size = Vector2(_s(520), _s(560))
	center.add_child(card)

	# ===== VBox do conteúdo =====
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", int(_s(12)))
	# Margens internas do card
	vbox.anchor_left = 0
	vbox.anchor_right = 1
	vbox.offset_left = _s(24)
	vbox.offset_right = -_s(24)
	card.add_child(vbox)

	# ===== Título =====
	var title := Label.new()
	title.name = "Title"
	title.text = "Resistência"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", int(_s(32)))
	title.add_theme_color_override("font_color", Color(0.93, 0.90, 0.82, 1))
	vbox.add_child(title)

	# Espaço
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, _s(16))
	vbox.add_child(sep)

	# ===== Botões =====
	btn_play     = _mk_button("Novo Jogo",  "BtnPlay")
	btn_continue = _mk_button("Continuar",  "BtnContinue")
	btn_options  = _mk_button("Opções",     "BtnOptions")
	btn_credits  = _mk_button("Créditos",   "BtnCredits")
	btn_quit     = _mk_button("Sair",       "BtnQuit")

	for b in [btn_play, btn_continue, btn_options, btn_credits, btn_quit]:
		vbox.add_child(b)

	# Estado do "Continuar"
	btn_continue.disabled = not FileAccess.file_exists("user://savegame.dat")

	# Foco inicial
	btn_play.grab_focus()

func _mk_button(text: String, node_name: String) -> Button:
	var b := Button.new()
	b.name = node_name
	b.text = text
	b.custom_minimum_size = Vector2(_s(300), _s(52))
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", int(_s(20)))
	return b

func _connect_logic() -> void:
	btn_play.pressed.connect(_on_play)
	btn_continue.pressed.connect(_on_continue)
	btn_options.pressed.connect(_on_options)
	btn_credits.pressed.connect(_on_credits)
	btn_quit.pressed.connect(func(): get_tree().quit())

func _apply_styles() -> void:
	# ----- Card -----
	var card := $"CenterContainer/Card" as Panel
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_corner_radius_all(int(_s(16)))
	sb.set_border_width_all(int(_s(1)))
	sb.border_color = Color8(85, 107, 47, 200)   # verde-oliva
	sb.shadow_size = int(_s(12))
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.set_content_margin_all(_s(20))
	card.add_theme_stylebox_override("panel", sb)

	# ----- Botões -----
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

	for b in [btn_play, btn_continue, btn_options, btn_credits, btn_quit]:
		b.add_theme_stylebox_override("normal", normal)
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("pressed", pressed)
		b.add_theme_stylebox_override("focus", focus)
		# Pulse sutil no hover/focus
		b.scale = Vector2.ONE
		b.mouse_entered.connect(func(): _pulse(b, 1.03))
		b.mouse_exited.connect(func(): _pulse(b, 1.0))
		b.focus_entered.connect(func(): _pulse(b, 1.03))
		b.focus_exited.connect(func(): _pulse(b, 1.0))

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
	var t := create_tween().set_loops()   # loop infinito
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

# ===== Callbacks =====
func _on_play() -> void:
	print("Novo Jogo -> Carregando Cutscene")
	
	# Esta linha foi alterada:
	get_tree().change_scene_to_file("res://main_menu/Cutscene1.tscn")

func _on_continue() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		print("Continuar jogo")

func _on_options() -> void:
	print("Abrir Opções")

func _on_credits() -> void:
	print("Abrir Créditos")
