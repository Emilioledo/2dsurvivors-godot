extends CharacterBody2D

const MAX_SPEED: int = 125
const ACCELERATION_SMOOTHING: int = 25

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar

var number_colliding_bodies = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.healt_changed.connect(on_health_changed)
	update_health_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_vector: Vector2 = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()

func get_movement_vector():
	var x_movement = Input.get_action_strength("player_move_right") - Input.get_action_strength("player_move_left")
	var y_movement = Input.get_action_strength("player_move_down") - Input.get_action_strength("player_move_up")
	return Vector2(x_movement, y_movement)
	
func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()
	print(health_component.current_health)

func update_health_display():
	health_bar.value = health_component.get_healt_percent()

func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1 
	check_deal_damage()

func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1 

func on_damage_interval_timer_timeout():
	check_deal_damage()

func on_health_changed():
	update_health_display()
