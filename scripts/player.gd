# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
extends CharacterBody2D

enum Stance {
	One = 1,
	Two = 2,
	Three = 3
}
var stance: Stance = Stance.One;

var StanceOne = preload("res://assets/SlashOne.png") # Loaded here so they won't lag when being swapped out
var StanceTwo = preload("res://assets/SlashTwo.png")
var StanceThree = preload("res://assets/SlashThree.png")
var stance_switch = false

const ability_one_time: float = 0.300 # ability_one() affects this.
const stance_time: float = 1.500
const ability_one_cd: float = 5.000
var ability_one_ready: bool = true
var movement_speed: int = 150
var is_moving: bool = false
var target_position = Vector2()
var already_damaged = []


func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	scale = Vector2(0.25, 0.25)
	get_node("AbilityOneTime").timeout.connect(self._on_ability_one_time_timeout)
	get_node("AbilityOneTime").wait_time = ability_one_time
	get_node("AbilityOneTime").one_shot = false
	get_node("AbilityOneTime").autostart = false
	get_node("StanceTime").timeout.connect(self._on_stance_time_timeout)
	get_node("StanceTime").wait_time = stance_time
	get_node("StanceTime").one_shot = false
	get_node("StanceTime").autostart = false
	get_node("AbilityOneCD").timeout.connect(self._on_ability_one_cd_timeout)
	get_node("AbilityOneCD").wait_time = ability_one_cd
	get_node("AbilityOneCD").one_shot = false
	get_node("AbilityOneCD").autostart = false
	$AbilityOne2D.visible = false
	$AbilityOne2D.texture = StanceOne
	$Weapon.z_index = 1
	$AbilityOne2D.z_index = 2
	get_node("AbilityOne2D").get_node("StanceOne").monitoring = false
	get_node("AbilityOne2D").get_node("StanceTwo").monitoring = false
	get_node("AbilityOne2D").get_node("StanceThree").monitoring = false

func _process(_delta: float) -> void:
	pass

#Use this for physics movements etcetera
func _physics_process(delta):
	move(delta)

#This is WASD movement. Kept for reusability, but commented out because we are going for MOBA-style movement
#func move(delta: float) -> void:
	#if Input.is_action_pressed("left"):
		#velocity.x = -movement_speed
	#if Input.is_action_pressed("right"):
		#velocity.x = movement_speed
	#if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		#velocity.x = 0
	#if Input.is_action_pressed("up"):
		#velocity.y = -movement_speed
	#if Input.is_action_pressed("down"):
		#velocity.y = movement_speed
	#if Input.is_action_pressed("up") and Input.is_action_pressed("down"):
		#velocity.y = 0
	#velocity = velocity.normalized() * movement_speed * delta
	#move_and_collide(velocity)
	#velocity = Vector2.ZERO

func move(delta: float) -> void:
	if is_moving == true and is_multiplayer_authority(): #Make sure only the proper user is controlling
		var direction = (target_position - position).normalized()
		velocity = direction * movement_speed * delta
		var collision = move_and_collide(velocity)
		if collision:
			is_moving = false
			velocity = Vector2.ZERO
		if position.distance_to(target_position) < 10:
			is_moving = false
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

# Starts the timer identified by its node name and sets its wait_time property
func start_timer(timer_name: String, wait_time: float):
	get_node(timer_name).start(wait_time)

# Stops the timer specified by its node name
func stop_timer(timer_name: String):
	get_node(timer_name).stop()

func _on_ability_one_time_timeout() -> void:
	$Weapon.rotation_degrees = 0
	$AbilityOne2D.rotation_degrees = 0
	$AbilityOne2D.visible = false
	$AbilityOne2D/StanceOne.monitoring = false
	$AbilityOne2D/StanceTwo.monitoring = false
	$AbilityOne2D/StanceThree.monitoring = false

func _on_stance_time_timeout() -> void:
	#ability_one_ready = true REVIEW THIS
	start_timer("AbilityOneCD", ability_one_cd)
	stance = Stance.One

func _on_ability_one_cd_timeout() -> void:
	ability_one_ready = true

#input is being handled by network script on Level node
#func _input(_event):
	#if is_multiplayer_authority():
		#if Input.is_action_just_pressed("move"):
			#target_position = get_global_mouse_position()
			#is_moving = true # process() calls move() every frame which only executes while this variable is true
		#if Input.is_action_just_pressed("attack"):
			#attack()
		#if Input.is_action_just_pressed("ability_one") and ability_one_ready == true:
			#ability_one()

func attack():
	pass

func ability_one() -> void:
	if ability_one_ready == false:
		return #Important to prevent using ability while on cooldown
	ability_one_ready = false
	var direction = get_global_mouse_position() - global_position
	direction = direction.normalized()
	var angle = rad_to_deg(direction.angle())
	$AbilityOne2D.visible = false
	$Weapon.rotation_degrees = angle + 90 # I don't know why it needs this offset, but it does
	$AbilityOne2D.rotation_degrees = angle + 90
	already_damaged.clear() # Need to clear this list because we're doing a new instance of damage
	match stance:
		Stance.One:
			$AbilityOne2D.texture = StanceOne
			$AbilityOne2D/StanceTwo.monitoring = false
			$AbilityOne2D/StanceThree.monitoring = false
			$AbilityOne2D/StanceOne.monitoring = false
			$AbilityOne2D/StanceOne.monitoring = true
			start_timer("AbilityOneTime", ability_one_time)
			start_timer("StanceTime", stance_time)
			start_timer("AbilityOneCD", 0.100)
			stance = Stance.Two
		Stance.Two:
			$AbilityOne2D.texture = StanceTwo
			$AbilityOne2D/StanceOne.monitoring = false
			$AbilityOne2D/StanceThree.monitoring = false
			$AbilityOne2D/StanceTwo.monitoring = false
			$AbilityOne2D/StanceTwo.monitoring = true
			start_timer("AbilityOneTime", ability_one_time + 0.050)
			start_timer("StanceTime", stance_time)
			start_timer("AbilityOneCD", 0.100)
			stance = Stance.Three
		Stance.Three:
			$AbilityOne2D.texture = StanceThree
			$AbilityOne2D/StanceOne.monitoring = false
			$AbilityOne2D/StanceTwo.monitoring = false
			$AbilityOne2D/StanceThree.monitoring = false
			$AbilityOne2D/StanceThree.monitoring = true
			start_timer("AbilityOneTime", ability_one_time + 0.100)
			stop_timer("StanceTime")
			start_timer("AbilityOneCD", ability_one_cd)
			stance = Stance.One
	$AbilityOne2D.visible = true

#MAYBE USEFUL LOOK HERE: var overlapping_bodies = get_overlapping_bodies() TESTING
#One-time scan of area2D rather than relying on monitoring's perpetual detection
func do_damage(body: Node2D) -> void:
	if body.has_method("take_damage") and body.name != self.name and not already_damaged.has(body.name):
		print(str(self.name) + " damaged " + str(body.name))
		body.take_damage()
		already_damaged.append(body.name)

func take_damage():
	if $Health.value > 0:
		$Health.value -= 20
		print(str(self.name), " health reduced to " + str($Health.value))
	if $Health.value == 0:
		$Sprite2D.visible = false
		$Weapon.visible = false
		$Health.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Hitbox.set_deferred("monitorable", false)

func _on_stance_one_body_entered(body: Node2D) -> void:
	do_damage(body)

func _on_stance_two_body_entered(body: Node2D) -> void:
	do_damage(body)

func _on_stance_three_body_entered(body: Node2D) -> void:
	do_damage(body)
# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
