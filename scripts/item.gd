extends Button


var remove_on_click:bool = true;


func _ready() -> void:
	connect("button_up", self, "delete");  # warning-ignore:return_value_discarded

func delete() -> void:
	if remove_on_click:
		emit_signal("on_delete", self);


signal on_delete(node)
