extends Control


export(String) var input_text:String;
export(bool) var is_open:bool = true;
export(bool) var arrow_disabled = false;
onready var label:Label = $top_bar/label;
onready var arrow:TextureButton = $top_bar/CenterContainer/arrow;
var open_icon:Texture = preload("res://resources/flatBW_src/arrow_open.png");
var closed_icon:Texture = preload("res://resources/flatBW_src/arrow_closed.png");


func _ready() -> void:
	set_process(false);
	arrow.connect("button_up", self, "_toggled");  # warning-ignore:return_value_discarded
	label.text = input_text;
	arrow.disabled = arrow_disabled;
	
	set_arrow_texture(is_open);
	
	for node in get_children():
		if !(node.name == get_child(0).name):
			if is_open:
				node.show();
			else:
				node.hide();
		
func _toggled() -> void:
	is_open = !is_open;
	for node in get_children():
		if !(node.name == get_child(0).name):
			if is_open:
				node.show();
			else:
				node.hide();

	set_arrow_texture(is_open);

func set_arrow_texture(state:bool) -> void:
	var texture
	if state: texture = open_icon
	else: texture = closed_icon
	
	arrow.texture_normal = texture;
	arrow.texture_pressed = texture;
	arrow.texture_hover = texture;
	arrow.texture_focused = texture;
	arrow.texture_disabled = texture;

func disable_children(disabled:bool) -> void:
	for node in get_children():
		if !(node.name == get_child(0).name):
			node.disabled = disabled;

func disable_arrow(disabled:bool) -> void:
	arrow_disabled = disabled;
	arrow.disabled = disabled;

func open() -> void:
	is_open = true;
	for node in get_children():
		if !(node.name == get_child(0).name):
			node.show();
		
	set_arrow_texture(is_open);
	
func close() -> void:
	is_open = false;
	for node in get_children():
		if !(node.name == get_child(0).name):
			node.hide();
		
	set_arrow_texture(is_open);
