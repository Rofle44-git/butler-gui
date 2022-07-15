extends HBoxContainer


export(String) var text:String = "";
onready var label:Label = $Label;


func _ready() -> void:
	label.text = text;
