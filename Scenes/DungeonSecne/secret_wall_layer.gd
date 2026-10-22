extends TileMapLayer

func disable_secret_wall() -> void:
	visible = false
	collision_enabled = false

func enable_secret_wall() -> void:
	visible = true
	collision_enabled = true
