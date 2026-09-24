extends Resource
class_name ConsoleBackend

signal terminal_new_text
signal terminal_new_line
signal terminal_new_table

var commands: Dictionary[String, Command]
var source_id:= "ConsoleBackend"
var frontend: Node

func _frontend_ready():
	_backend_ready()
	frontend.line_edit_update.connect(on_line_edit_update).bind("")

func _backend_ready():
	pass

func on_line_edit_update(text: String):
	var result_dict: Dictionary = parse_input_string(text)
	pass




#	Testaa
func on_terminal_input_submitted(input_text: String):
	var result = parse_input_string(input_text)
	var command = _fetch_command(result["command"])
	var param_types: Array = match_parameter_types(command.main_function)
	if param_types.size() > command.main_function.get_argument_count():
		#Error handling
		return
	if result["arguments"].size() < param_types.size():
		#Error handling again
		return

	var matched_arguments: Array	
	for t in param_types.size():
		var match_results = Ses.match_type_strict(result["arguments"][t],param_types[t])
		matched_arguments.append(match_results)
	if result["extensions"].size()==0:
		_run_command_from_terminal(command.selected_id)
	else:
		var extension = result["extension"][0]
		_run_command_extension(command, extension, matched_arguments)



func fetch_suggestions(input: String = ""):
	var parsed_input = format_ext_path_string(input)
	var command_id: String = parsed_input.pop_front()
	if parsed_input.is_empty():
		if command_id.ends_with(".") == false:
			return _text_search(commands, input, false)
		else:
			pass

	match parsed_input.size():
		0:
			return []
		1:
			return _text_search(commands, input)
		_:


			pass

"""
On match selected:
	Command.get_extcommands[command]


"""
func search_command_extensions(dict: Dictionary, input: String):

	pass


func _text_search(dict: Dictionary, input: String = "", show_all_on_empty_input: bool = false)-> Array:
	var matches: Array[String] = []
	if input == "" and show_all_on_empty_input == false:
		return matches
	var cleaned_input: String = input.to_lower()
	for key in dict.keys():
		var key_str: String = String(key).to_lower()
		if key_str.begins_with(cleaned_input):
			matches.append(String(key))
	return matches


func _fetch_command(command_str: String):
	var command_id = commands.get(command_str, -1)
	if command_id == -1:
		#ERROR HANDLING
		return
	var command: Command = commands.get(command_id)
	return command



func format_ext_path_string(input: String, packed: bool = false):
	var packed_string_array: PackedStringArray = input.split(".", false)
	if packed == true:
		return packed_string_array
	else:
		var result: Array = Array(packed_string_array)
		return result


func parse_input_string(text: String):
	var command: String
	var extensions: Array[String]
	var type_split: Array = text.split(" ", false, 2)	
	var command_split = type_split[0].split(".", false)
	var argument_split: Array = []
	if type_split.size() > 1:
		argument_split = type_split[1].split(" ", false)

	command = command_split.pop_front()
	extensions = command_split

	var result: Dictionary = {
		"command": command,
		"extensions": extensions,
		"arguments": argument_split
	}
	return result


func _run_command_from_terminal(command: Command, ...args):
	command.run_cmd(args)


func _run_command_extension(command: Command, extension: Array, arguments: Array):
	command.run_ext(extension, arguments)



func add_command(cmd_id: String, callable: Callable, replace: bool = false):
	if commands.has(cmd_id):
		pass
	else:
		commands.set(cmd_id, callable)


func print_text(...args: Array) -> void:
	var stringed_array: Array = args.map(func(item):return str(item))
#	var packed_string_array: P
	terminal_new_text.emit()


func new_line():
	terminal_new_line.emit()

#func print_table():
#	pass


func match_parameter_types(callable: Callable) -> Array:
	var types: Array[Variant.Type]
	var obj: Object = callable.get_object()
	
	if callable.is_valid() == false:
		return types
	
	for method in obj.get_method_list():
		if method["name"] == callable.get_method():
			for arg in method["args"]:
				types.append(arg["type"] as Variant.Type)
				break

	return types
