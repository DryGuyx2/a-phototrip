extends AudioStreamPlayer

func _on_dialogue_label_spoke(letter, letter_index, speed):
	if not letter in [".", " "]:
		play()
