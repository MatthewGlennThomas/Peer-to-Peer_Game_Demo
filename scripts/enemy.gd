# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
extends CharacterBody2D

func _ready() -> void:
	scale = Vector2(0.25, 0.25)
	position = Vector2(960,540)

func take_damage():
	if $Health.value > 0:
		$Health.value -= 20
	if $Health.value == 0:
		$Sprite2D.visible = false
		#$Weapon.visible = false
		$Health.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Hitbox.set_deferred("monitorable", false)
# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
