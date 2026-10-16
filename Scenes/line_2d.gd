extends Line2D

func _ready():
	current_rope_length = rope_length
	chain_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
