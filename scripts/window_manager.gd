extends VBoxContainer


onready var minimize = $PanelContainer/VBoxContainer/taskbar/taskbar_margin/icons/minimize;
onready var close = $PanelContainer/VBoxContainer/taskbar/taskbar_margin/icons/close;
onready var taskbar = $PanelContainer/VBoxContainer/taskbar;
onready var screen_container = $PanelContainer/VBoxContainer;

var current_screen;


func _ready() -> void:
	get_tree().get_root().set_transparent_background(true);
	OS.window_per_pixel_transparency_enabled = true;
	
	minimize.connect("button_up", self, "_minimize");  # warning-ignore:return_value_discarded
	close.connect("button_up", self, "_close");  # warning-ignore:return_value_discarded
	
func _finished_loading() -> void:
	yield(get_tree(), "idle_frame")
	current_screen = res.scenes[res.MAIN].instance();
	screen_container.add_child(current_screen);

func _minimize() -> void:
	OS.window_minimized = true;
	
func _close() -> void:
	get_tree().quit();
