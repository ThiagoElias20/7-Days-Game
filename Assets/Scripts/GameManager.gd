# GameManager.gd
extends Node

# Variável para rastrear a quantidade de panfletos
var flyers_placed: int = 0

# Sinal para notificar a HUD quando o valor muda
signal flyer_count_changed(new_count)

# Função para aumentar a contagem e emitir o sinal
func place_flyer():
	flyers_placed += 1
	# Emite o sinal para que a HUD possa se atualizar
	emit_signal("flyer_count_changed", flyers_placed)
