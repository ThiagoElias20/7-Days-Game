extends TextureRect


func _ready():
	# Começa fora da tela (em cima)
	position.y = -texture.get_height()
	# Espera meio segundo e começa a descer
	await get_tree().create_timer(0.5).timeout
	descer_e_sumir()


func descer_e_sumir():
	var tween = create_tween()
	# Desce até a posição visível (ajuste conforme sua resolução)
	tween.tween_property(self, "position:y", 0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Espera 1 segundo parado
	tween.tween_interval(20.0)
	# Sobe novamente e some
	tween.tween_property(self, "position:y", -texture.get_height(), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Opcional: esconder depois de sumir
	tween.tween_callback(hide)
