extends Control
class_name BetterTree


export(String) var label_text:String = "";
onready var item_container:VBoxContainer = $VBoxContainer2/MarginContainer/ScrollContainer/items;
var button_scene:PackedScene = preload("res://resources/item.tscn");
var button_cache:Button;


func _on_delete(node) -> void:
	emit_signal("item_removed", get_item_index(node.text));
	node.queue_free();

func _ready() -> void:
	$VBoxContainer2/Label.text = label_text;

func add_item(text:String, remove_on_click:bool = true) -> void:
	if get_item_index(text) != -1:
		remove_item(get_item_index(text));
	button_cache = button_scene.instance();
	button_cache.text = text;
	button_cache.size_flags_horizontal = SIZE_EXPAND_FILL;
	button_cache.size_flags_vertical = SIZE_FILL;
	button_cache.remove_on_click = remove_on_click;
	button_cache.connect("on_delete", self, "_on_delete");  # warning-ignore:return_value_discarded
	item_container.add_child(button_cache);

func clear() -> void:
	for item in item_container.get_children():
		item.queue_free();

func get_item_index(text:String) -> int:
	for item in item_container.get_children():
		if item.text == text:
			return item_container.get_children().find(item);
	
	return -1;
	
func get_item_text(index:int) -> String:
	if index < item_container.get_child_count():
		return item_container.get_child(index).text;
	
	else:
		return "";

func get_all_text() -> Array:
	var tmp:Array = [];
	for item in item_container.get_children():
		tmp.append(item.text);
	
	return tmp;

func remove_item(index:int) -> void:
	if (index < item_container.get_child_count() and index > -1): item_container.get_child(index).queue_free();


signal item_removed(index)
