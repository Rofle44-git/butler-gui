extends Control


onready var output:BetterTree = $base_margin/VSplitContainer/output;

onready var auto_queue:Button = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/HBoxContainer/auto_queue;
onready var path_dialog:FileDialogButton = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/HBoxContainer/path_dialog;
onready var settings:Button = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/HBoxContainer/settings;
onready var username:OptionButton = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/username;
onready var game_title:OptionButton = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/game_title;
onready var platform:OptionButton = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/platform;
onready var type:OptionButton = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/type;
onready var add_to_queue:Button = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/add;
onready var push_all:Button = $base_margin/VSplitContainer/gui/MarginContainer/VBoxContainer/GridContainer/push_all;

var auto_queue_instance:WindowDialog = null;
var file_dialog_instance:FileDialog = null;
var settings_instance:WindowDialog = null;
var confirm_dialog_instance:ConfirmationDialog = null;
var butler_runner_dialog:WindowDialog = null;
var err_duplicate_command:AcceptDialog;
var err_spaces_in_name:AcceptDialog;
var warn_empty_queue:ConfirmationDialog;

var push_queue:Array = [];

var directory:String = "<build-directory>";
var user:String = "<user>";
var game:String = "<game>";
var channel_platform:String = "<channel_platform>";
var channel_type:String = "<channel_type>";


func _ready() -> void:
	# Signals
	auto_queue.connect("button_up", self, "_auto_queue");  # warning-ignore:return_value_discarded
	path_dialog.connect("dir_selected", self, "_path_dialog_get");  # warning-ignore:return_value_discarded
	settings.connect("button_up", self, "_settings");  # warning-ignore:return_value_discarded
	username.connect("item_selected", self, "update_output")  # warning-ignore:return_value_discarded
	game_title.connect("item_selected", self, "update_output")  # warning-ignore:return_value_discarded
	platform.connect("item_selected", self, "update_output")  # warning-ignore:return_value_discarded
	type.connect("item_selected", self, "update_output")  # warning-ignore:return_value_discarded
	add_to_queue.connect("button_up", self, "_add_to_queue");  # warning-ignore:return_value_discarded
	push_all.connect("button_up", self, "_push_all");  # warning-ignore:return_value_discarded	
	output.connect("item_removed", self, "remove_cell");  # warning-ignore:return_value_discarded	
	
	# Popups
	err_duplicate_command = res.scenes[res.ERR_DUPLICATE_COMMAND].instance();
	add_child(err_duplicate_command);
	err_spaces_in_name = res.scenes[res.ERR_SPACES_IN_NAME].instance();
	add_child(err_spaces_in_name);
	warn_empty_queue = res.scenes[res.WARN_EMPTY_QUEUE].instance();
	add_child(warn_empty_queue);
	
	push_all.disabled = true;
	
	reload_config();
	
	update_output();

func reload_config() -> void:
	username.clear();
	for item in res.config['usernames']:
		username.add_item(item);
		
	game_title.clear();
	for item in res.config['games']:
		game_title.add_item(item);
		
	platform.clear();
	for item in res.config['platforms']:
		platform.add_item(item);
	
	type.clear();
	for item in res.config['types']:
		type.add_item(item);

func _settings() -> void:
	settings_instance = res.scenes[res.SETTINGS].instance();
	add_child(settings_instance);
	settings_instance.connect("popup_hide", self, "_settings_hide");  # warning-ignore:return_value_discarded
	settings_instance.popup_centered();

func _settings_hide() -> void:
	reload_config();
	if settings_instance != null:
		settings_instance.queue_free();
		settings_instance = null;

func _auto_queue() -> void:
	auto_queue_instance = res.scenes[res.AUTO_QUEUE_DIALOG].instance();
	auto_queue_instance.connect("popup_done", self, "_auto_queue_get");  # warning-ignore:return_value_discarded	
	auto_queue_instance.connect("popup_hide", self, "_auto_queue_hide");  # warning-ignore:return_value_discarded	
	add_child(auto_queue_instance);
	auto_queue_instance.popup_centered();

func _path_dialog_get(dir:String) -> void:
	directory = dir;
	update_output();

func _auto_queue_get(commands:Array) -> void:
	if commands[0] == null: return
	else: push_queue = commands;
	update_output();

func _auto_queue_hide() -> void:
	auto_queue_instance.queue_free();
	auto_queue_instance = null;

func remove_cell(index) -> void:
	if res.config['preview_command']:
		push_queue.pop_at(index -1);
	else:
		push_queue.pop_at(index);

	update_output();
	
func update_output(__=null) -> void:
	user = username.get_item_text(username.selected);
	game = game_title.get_item_text(game_title.selected);
	channel_platform = platform.get_item_text(platform.selected);
	channel_type = type.get_item_text(type.selected);
	
	# Check active command
	# If it's invalid, disable pushing
	push_all.disabled = !command_valid(get_active_command());
	
	# Check push queue
	# If any are invalid, disable pushing
	for command in push_queue:
		if !command_valid(command):
			push_all.disabled = true;
			break;
		else:
			push_all.disabled = false;
	
	yield(get_tree(), "idle_frame");  # Waits one frame because something is cock-blocking the clear function
	
	# Updating treeview
	output.clear();

	if res.config['preview_command']:
		output.add_item("Preview: " + get_active_command(), false);
	
	for command in push_queue:
		output.add_item(command, true);

func command_valid(command:String) -> bool:
	return !(command in ["<directory>", "NULL"]);

func get_active_command() -> String:
	return res.BASE_COMMAND.replace(
		"<directory>", directory).replace(
			"<username>", user).replace(
				"<game>", game).replace(
					"<platform>", channel_platform).replace(
						"<type>", channel_type);

func _add_to_queue() -> void:
	if push_queue.has(get_active_command()):
		err_duplicate_command.popup_centered();
	else:
		push_queue.append(get_active_command());
	
	update_output();

func _push_all() -> void:
	if push_queue == []:
		warn_empty_queue.popup_centered();
		yield(warn_empty_queue, "confirmed");
		push_queue = [get_active_command()];
	
	if confirm_dialog_instance != null: confirm_dialog_instance.queue_free();
	confirm_dialog_instance = res.scenes[res.CONFIRMATION_DIALOG].instance();
	confirm_dialog_instance.connect("confirmed", self, "start_push_queue");  # warning-ignore:return_value_discarded
	confirm_dialog_instance.connect("popup_hide", self, "_confirm_dialog_hide");  # warning-ignore:return_value_discarded
	add_child(confirm_dialog_instance);
	confirm_dialog_instance.popup_centered();

func _confirm_dialog_hide() -> void:
	if confirm_dialog_instance != null:
		confirm_dialog_instance.queue_free();
		confirm_dialog_instance = null;

func start_push_queue() -> void:
	butler_runner_dialog = res.scenes[res.BUTLER_RUNNER].instance();
	add_child(butler_runner_dialog);
	butler_runner_dialog.popup_centered();
	butler_runner_dialog.commands = push_queue;
	yield(get_tree(), "idle_frame");
	butler_runner_dialog.start();
