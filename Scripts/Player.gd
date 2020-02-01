extends KinematicBody
 
const MOVE_SPEED = 500
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 
onready var cam = $Camera
onready var anim = $Sprite/AnimationPlayer
 
var y_velo = 0
 
func _ready():
	anim.get_animation("Walk").set_loop(true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("up"):
		move_vec.z += delta
	if Input.is_action_pressed("down"):
		move_vec.z -= delta
	if Input.is_action_pressed("right"):
		move_vec.x -= delta
	if Input.is_action_pressed("left"):
		move_vec.x += delta
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED * delta
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
   
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_just_pressed("Jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
   
	if just_jumped:
		play_anim("Jump")
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			play_anim("Idle")
		else:
			play_anim("Walk")
 
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)
