extends NetworkObject

func move(wishdir:Vector3):
	$PlayerBody.move(wishdir)

func jump():
	$PlayerBody.jump()

func get_pos():
	return $PlayerBody.global_position
