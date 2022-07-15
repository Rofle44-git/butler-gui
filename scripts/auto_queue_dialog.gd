extends WindowDialog


var commands:Array = [null];

onready var directory:FileDialogButton = get_node("margin/ScrollContainer/VBoxContainer/1/select_dir");
onready var username:OptionButton = get_node("margin/ScrollContainer/VBoxContainer/2/username/username");
onready var game:OptionButton = get_node("margin/ScrollContainer/VBoxContainer/3/game/game");
onready var name_structure:OptionButton = get_node("margin/ScrollContainer/VBoxContainer/4/HBoxContainer/folder_name_structure");
onready var type:OptionButton = get_node("margin/ScrollContainer/VBoxContainer/5/HBoxContainer3/shared_type");
onready var scan:Button = get_node("margin/ScrollContainer/VBoxContainer/6/scan");
onready var folders:Array = [];

var _directory:String = "";
var _username:String;
var _game:String;
var _name_structure = null;
var _type:String;

var directory_popup_instance:FileDialog;
var scan_directory:Directory;
var file_path:String;
var platform_type_regex:RegEx = RegEx.new();
var platform_regex:RegEx = RegEx.new();
var result_array:Array;
var regex_result:RegExMatch;

enum NAME_STRUCTURES {
	PLATFORM_TYPE,
	PLATFORM
}


func _ready() -> void:
	connect("popup_hide", self, "_main_popup_hide");  # warning-ignore:return_value_discarded
	directory.connect("dir_selected", self, "_directory_get");  # warning-ignore:return_value_discarded
	username.connect("item_selected", self, "_username_get");  # warning-ignore:return_value_discarded
	game.connect("item_selected", self, "_game_get");  # warning-ignore:return_value_discarded
	name_structure.connect("item_selected", self, "_name_structure_get");  # warning-ignore:return_value_discarded
	type.connect("item_selected", self, "_type_get");  # warning-ignore:return_value_discarded
	scan.connect("button_up", self, "_scan_start");  # warning-ignore:return_value_discarded
	
	reload_config();
	
	username.select(-1);
	username.text = "-SELECT-";
	game.select(-1);
	game.text = "-SELECT-";
	name_structure.select(-1);
	name_structure.text = "-SELECT-";
	name_structure.disabled = true;
	type.disabled = true;
	type.select(-1);
	type.text = "-SELECT-";
	
	for folder in $margin/ScrollContainer/VBoxContainer.get_children():
		folders.append(folder);
		folder.disable_arrow(true);
		folder.close();
		
	folders[0].open();
	
	platform_type_regex.compile("[a-z]+");  # warning-ignore:return_value_discarded
	platform_regex.compile("^[a-z]+");  # warning-ignore:return_value_discarded
	
	yield(get_tree(), "idle_frame");
	directory.grab_click_focus();
	directory.grab_focus();

func reload_config() -> void:
	username.clear();
	for item in res.config['usernames']:
		username.add_item(item);
		
	game.clear();
	for item in res.config['games']:
		game.add_item(item);
	
	type.clear();	
	for item in res.config['types']:
		type.add_item(item);

func _main_popup_hide() -> void:
	emit_signal("popup_done", commands);

func _directory_get(dir:String) -> void:
	_directory = dir;
	if _directory != "": name_structure.disabled = false;
	else:  name_structure.disabled = true
	if directory_popup_instance != null: directory_popup_instance.queue_free(); directory_popup_instance = null;
	folders[1].open();
	yield(get_tree(), "idle_frame");
	username.grab_click_focus();
	username.grab_focus();

func _username_get(idx:int) -> void:
	_username = username.get_item_text(idx);
	folders[2].open();
	yield(get_tree(), "idle_frame");
	game.grab_click_focus();
	game.grab_focus();

func _game_get(idx:int) -> void:
	_game = game.get_item_text(idx);
	folders[3].open();
	yield(get_tree(), "idle_frame");
	name_structure.grab_click_focus();
	name_structure.grab_focus();

func _name_structure_get(idx:int) -> void:
	_name_structure = idx;
	match _name_structure:
		NAME_STRUCTURES.PLATFORM_TYPE:
			type.disabled = true;
			folders[5].open();
			folders[4].close();
			yield(get_tree(), "idle_frame");
			scan.grab_click_focus();
			scan.grab_focus();
		
		NAME_STRUCTURES.PLATFORM:
			type.disabled = false;
			folders[4].open();
			folders[5].close();
			yield(get_tree(), "idle_frame");
			type.grab_click_focus();
			type.grab_focus();

func _type_get(idx:int) -> void:
	_type = type.get_item_text(idx);
	folders[5].open();
	yield(get_tree(), "idle_frame");
	scan.grab_click_focus();
	scan.grab_focus();
	
func _scan_start():
	commands = [];
	
	scan_directory = Directory.new();
	if scan_directory.open(_directory) == OK:
		scan_directory.list_dir_begin();  # warning-ignore:return_value_discarded
		file_path = scan_directory.get_next();
		while file_path != "":
			if scan_directory.current_is_dir():
				match _name_structure:
					NAME_STRUCTURES.PLATFORM_TYPE:
						result_array = platform_type_regex.search_all(file_path);
						if result_array != []:
							commands.append(res.BASE_COMMAND.replace(
								"<directory>", _directory + "/" + file_path).replace(
									"<username>", _username).replace(
										"<game>", _game).replace(
											"<platform>", result_array[0].get_string()).replace(
												"<type>", result_array[1].get_string()));
						
					NAME_STRUCTURES.PLATFORM:
						regex_result = platform_regex.search(file_path);
						if regex_result != null:
							commands.append(res.BASE_COMMAND.replace(
								"<directory>", _directory + "/" + file_path).replace(
									"<username>", _username).replace(
										"<game>", _game).replace(
											"<platform>", regex_result.get_string()).replace(
												"<type>", _type));
				
			file_path = scan_directory.get_next();
	
	if commands == []: commands = [null];
	hide();


signal popup_done(commands)
