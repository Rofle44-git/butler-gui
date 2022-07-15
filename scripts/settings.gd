extends WindowDialog


# User
onready var usernames:LineEdit = $VBoxContainer/TabContainer/user/MarginContainer/ScrollContainer/GridContainer/usernames;
onready var games:LineEdit = $VBoxContainer/TabContainer/user/MarginContainer/ScrollContainer/GridContainer/games;
onready var platforms:LineEdit = $VBoxContainer/TabContainer/user/MarginContainer/ScrollContainer/GridContainer/platforms;
onready var types:LineEdit = $VBoxContainer/TabContainer/user/MarginContainer/ScrollContainer/GridContainer/types;

# Behaviour
onready var preview_command:CheckBox = $VBoxContainer/TabContainer/behaviour/MarginContainer3/ScrollContainer/GridContainer/HBoxContainer/preview;

# Style
onready var theme_selector:OptionButton = $VBoxContainer/TabContainer/style/MarginContainer3/ScrollContainer/GridContainer/theme;

# Other
onready var wm = get_node("/root/window_manager");
onready var reset:Button = $VBoxContainer/HBoxContainer2/reset;
onready var save:Button = $VBoxContainer/HBoxContainer2/save;

var themes:Array = [];


func _ready() -> void:
	reset.connect("button_up", self, "_reset");  # warning-ignore:return_value_discarded
	save.connect("button_up", self, "_save");  # warning-ignore:return_value_discarded
	
	reload_config();
	scan_themes();

func reload_config() -> void:
	usernames.text = str(res.config['usernames']).replace("[", "").replace("]", "");
	games.text = str(res.config['games']).replace("[", "").replace("]", "");
	platforms.text = str(res.config['platforms']).replace("[", "").replace("]", "");
	types.text = str(res.config['types']).replace("[", "").replace("]", "");
	
	preview_command.pressed = res.config['preview_command'];

func scan_themes() -> void:
	theme_selector.clear();
	themes.clear();
	
	theme_selector.add_item("default");
	themes.append("res://resources/flatBW.tres");
	
	for user_theme in res.scan_dir(res.THEME_PATH, true, false):
		if themes.find(user_theme) == -1:
			themes.append(user_theme)
			theme_selector.add_item(user_theme.get_basename().replace(user_theme.get_base_dir(), "").replace("/", ""), -1);
	
	theme_selector.selected = themes.find(res.config['theme']);

func _reset() -> void:
	res.load_config();
	yield(res, "config_updated");
	reload_config();
	
func _save() -> void:
	res.config['usernames'] = Array(usernames.text.split(", ", false, 0));
	res.config['games'] = Array(games.text.split(", ", false, 0));
	res.config['platforms'] = Array(platforms.text.split(", ", false, 0));
	res.config['types'] = Array(types.text.split(", ", false, 0));
	if theme_selector.get_item_count() > 0:
		res.config['theme'] = themes[theme_selector.selected];

	res.config['preview_command'] = preview_command.pressed;
	
	res.save_config();
	res.reload_theme();
