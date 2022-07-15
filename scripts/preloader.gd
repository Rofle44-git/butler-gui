extends Node


onready var loading_screen:Control = $CanvasLayer/loading_screen;
onready var window_manager:Control = get_node("/root/window_manager");
# Example: butler push linux_x86_64/ lenny44/cubic-argon-platform:linux-alpha
const BASE_COMMAND = "butler push <directory> <username>/<game>:<platform>-<type>";
const DEFAULT_CONFIG = {
	# Data
	'usernames': ["NULL"],
	'games': ["NULL"],
	'platforms': ["NULL"],
	'types': ["NULL"],
	# Behaviour
	'preview_command': true,
	'remember_directory': false,
	'recent_directory': '',
	# Style
	'theme':'res://resources/flatBW.tres'
	};
const CONFIG_PATH = "user://config.json";
const THEME_PATH = "user://themes";

var scenes:Array = [];
var config:Dictionary;

enum {
	MAIN,
	AUTO_QUEUE_DIALOG,
	BUTLER_RUNNER,
	CONFIRMATION_DIALOG,
	ERR_DUPLICATE_COMMAND,
	ERR_SPACES_IN_NAME,
	WARN_EMPTY_QUEUE,
	SETTINGS};

enum TEST_FILE_ERROR {
	OK,
	NOT_FOUND,
	EMPTY,
	CORRUPTED};


func _ready() -> void:
	connect("finished_loading", window_manager, "_finished_loading");  # warning-ignore:return_value_discarded
	_loading_sequence();
	reload_theme(config['theme']);

func _loading_sequence() -> void:
	scenes = [
		preload("res://screens/main.tscn"),
		preload("res://screens/auto_queue_dialog.tscn"),
		preload("res://screens/butler_runner.tscn"),
		preload("res://screens/push_confirmation_dialog.tscn"),
		preload("res://screens/errors/err_duplicate_command.tscn"),
		preload("res://screens/errors/err_spaces_in_name.tscn"),
		preload("res://screens/warnings/warn_empty_queue.tscn"),
		preload("res://screens/settings.tscn")];
	
	# Detect if setup required
	if test_file(CONFIG_PATH) == TEST_FILE_ERROR.OK:
		if !_test_dir(THEME_PATH):
			var tmp:Directory = Directory.new();
			tmp.open("user://")  # warning-ignore:return_value_discarded
			tmp.make_dir("themes");  # warning-ignore:return_value_discarded
		
		load_config();
		
	else:
		_setup();
	
	emit_signal("finished_loading");
	loading_screen.hide();

func _test_dir(dir:String) -> bool:
	var tmp:Directory = Directory.new();
	return tmp.dir_exists(dir)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_config();
		get_tree().quit();

func _setup() -> void:
	save_config(DEFAULT_CONFIG);
	var tmp:Directory = Directory.new();
	tmp.open("user://")  # warning-ignore:return_value_discarded
	tmp.make_dir("themes");  # warning-ignore:return_value_discarded
	load_config();

func save_config(what=config) -> void:
	var f = File.new();
	f.open(CONFIG_PATH, File.WRITE);
	f.store_line(to_json(what));
	f.close();

func load_config() -> void:
	var f:File = File.new();
	var content;
	var error:int;
	
	error = f.open(CONFIG_PATH, File.READ);
	
	if error == ERR_FILE_NOT_FOUND:  # Error: File doesn't exist
		f.close();
		config = {};
		return;

	if f.get_as_text() == "":  # Error: Empty file
		f.close();
		config = {};
		return;
	
	# Get content
	content = parse_json(f.get_as_text());
	f.close();
	
	if content == null or (typeof(content) == 18 and content.empty()):  # Error: Corrupted data
		f.close();
		config = {};
		return;

	config = content;
	emit_signal("config_updated");

func test_file(file:String, test_json:bool=true) -> int:
	var f:File = File.new();
	var err:int = f.open(file, f.READ);
	if err == ERR_FILE_NOT_FOUND:
		f.close();
		return TEST_FILE_ERROR.NOT_FOUND;

	var content = f.get_as_text();
	var json_content = null;
	if test_json: json_content = parse_json(content);
	
	f.close();
	
	if err == OK:
		if content == "":
			return TEST_FILE_ERROR.EMPTY;
			
		elif test_json and json_content == null or (typeof(json_content) == 18 and json_content.empty()):
				return TEST_FILE_ERROR.CORRUPTED;
			
		else:
			return TEST_FILE_ERROR.OK;
	
	else:
		return TEST_FILE_ERROR.NOT_FOUND;

func scan_dir(dir:String, files:bool=true, dirs:bool=true) -> Array:
	var tmp:Directory = Directory.new();
	var f_name:String;
	var f_array:Array = [];
	if tmp.dir_exists(dir):
		
		if tmp.open(dir) == OK:
			tmp.list_dir_begin();  # warning-ignore:return_value_discarded
			f_name = tmp.get_next();
			
			while f_name != "":
				if tmp.current_is_dir():
					if dirs: f_array.append(dir + "/" + f_name);
				
				else:
					if files: f_array.append(dir + "/" + f_name);
					
				f_name = tmp.get_next();
				
			return f_array;
			
		else:
			return [];  # Error while opening directory
		
	else:
		return [];  # Error while opening directory

func reload_theme(path:String=config['theme']) -> void:
	if test_file(path, false) != TEST_FILE_ERROR.NOT_FOUND:
		print_debug("THEME %s FOUND. APPLYING..." % path);
		window_manager.theme = load(path)
		propagate_call("update");
	
	else:
		print_debug("THEME %s NOT FOUND. FALLING BACK TO THE DEFAULT THEME..." % path);
		ProjectSettings.set_setting("gui/theme/custom", "res://resources/flatBW.tres");
		propagate_call("update");

signal finished_loading
signal config_updated
