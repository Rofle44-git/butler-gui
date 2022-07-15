extends Control


onready var terminal = $PanelContainer/CenterContainer/PanelContainer/VBoxContainer/TextEdit
onready var prefix = $PanelContainer/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/prefix
onready var path = $PanelContainer/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/LineEdit
onready var list = $PanelContainer/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/list


func _ready():
	list.connect("button_up", self, "_list")
	path.connect("text_entered", self, "_list")
	
	_print("GDTerm v1.0\n", false);
	
	path.grab_focus()

func _print(text, dollar_sign:bool = true, new_line:bool = true):
	if dollar_sign: terminal.text += "$ ";
	terminal.text += text;
	if new_line: terminal.text += "\n";

func _list(__=null):
	terminal.text = ""
	path.text = prefix.get_item_text(prefix.selected) + path.text
	var files = []
	var folders = []
	var dir = Directory.new()
	_print("Searching in %s" % path.text)
	if dir.open(path.text) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != ".." and file_name != ".":
					folders.append(file_name)
			else:
				if file_name != ".." and file_name != ".":
					files.append(file_name)
			file_name = dir.get_next()
	else:
		_print("An error occurred when trying to access the path.")
	
	for _line in folders:
		_print("Found directory: " + _line)
		
	for _line in files:
		_print("Found file: " + _line)
		
	_print("\n")
	path.text = ""
