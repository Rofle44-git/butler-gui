extends WindowDialog


onready var terminal:TextEdit = $margin/VBoxContainer/terminal;
onready var progress:ProgressBar = $margin/VBoxContainer/HBoxContainer/ProgressBar;
onready var label:Label = $margin/VBoxContainer/HBoxContainer/PanelContainer/Label;

var commands:Array;
var converted_comands:Array;

var error_code:int;
var output:Array = [];


func start() -> void:
	for command in commands:
		converted_comands.append(convert_to_args(command));
	
	yield(get_tree(), "idle_frame");
	
	for command in converted_comands:
		update_values(
			converted_comands.find(command) + 1,
			converted_comands.size());

		terminal_print("Running command: %s" % "butler " + str(command));
		
		yield(get_tree(), "idle_frame");
		
		push(command);
		
		for line in output:
			terminal_print(line);
				
		terminal_print("Finished with code: %s" % error_code);
		
		update_values(
			converted_comands.find(command) + 1,
			converted_comands.size());
			
		yield(get_tree(), "idle_frame");

func update_values(current:int, maximum:int) -> void:
	label.text = "push %s/%s" % [current, maximum];
	progress.value = current;
	progress.max_value = maximum;

func terminal_print(text:String) -> void:
	terminal.text += text + "\n";

func convert_to_args(command:String) -> PoolStringArray:
	return command.replace("butler", "").split(" ", false, 0);

func push(args:PoolStringArray) -> void:
	error_code = OS.execute("butler", args, true, output);
