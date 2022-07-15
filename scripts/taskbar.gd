extends HBoxContainer


var moving_window:bool = false;
var mouse_start:Vector2;


func _ready():
	connect("mouse_entered", self, "mouse_entered");  # warning-ignore:return_value_discarded
	connect("mouse_exited", self, "mouse_exited");  # warning-ignore:return_value_discarded

func _process(_delta):
	if Input.is_action_just_pressed("lmb"):
		mouse_start = get_global_mouse_position();
			
	if Input.is_action_pressed("lmb") and moving_window:
		OS.window_position += get_global_mouse_position() - mouse_start;

func mouse_entered():
	moving_window = true;
	
func mouse_exited():
	moving_window = false;
