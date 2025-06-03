extends ParallaxBackground

var fixed_y_scroll := 0.0

func _ready() -> void:
	fixed_y_scroll = scroll_offset.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scroll_offset.y = fixed_y_scroll
