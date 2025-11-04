extends NetworkObject

func _ready() -> void:
	ID = rand_from_seed(hash(name))[0]
	print(ID)
	get_parent().addNetObject(self)
