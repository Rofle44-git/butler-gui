extends Button
class_name FileDialogButton


enum MODES {
	MODE_OPEN_FILE,
	MODE_OPEN_FILES,
	MODE_OPEN_DIR,
	MODE_OPEN_ANY,
	MODE_SAVE_FILE};
enum ACCESS {
	ACCESS_RESOURCES,
	ACCESS_USERDATA,
	ACCESS_FILESYSTEM};

export(MODES) var mode:int = 0;
export(ACCESS) var access:int = 0;
export(bool) var show_hidden_files:bool = false;

onready var file_dialog:FileDialog = $FileDialog;


func _ready() -> void:
	file_dialog.mode = mode;
	file_dialog.access = access;
	file_dialog.show_hidden_files = show_hidden_files;
	
	connect("button_up", self, "_file_dialog_show");  # warning-ignore:return_value_discarded
	file_dialog.connect("dir_selected", self, "_dir_selected");  # warning-ignore:return_value_discarded

func _file_dialog_show() -> void:
	file_dialog.popup_centered();

func _dir_selected(dir:String) -> void:
	emit_signal("dir_selected", dir);


signal dir_selected(dir)
