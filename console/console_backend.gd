extends Resource
class_name ConsoleBackend

enum{
	ANY,
	COMMAND,
	DICTIONARY,


}



signal terminal_new_text
signal terminal_new_line
signal terminal_new_table

signal suggestion_list_update

var commands: Dictionary = {}
var source_id:= "ConsoleBackend"
var frontend: Node

@export var command_prefabs: Array[Command]

func _frontend_ready():
	_backend_ready()
	frontend.line_edit_update.connect(on_line_edit_update)

func _backend_ready():
	pass	# Add prefabs!

func add_command(path: String, cmd_callable: Callable, overwrite: bool = false) -> String:
	var cmd: Command = Command.new()
	cmd.callable = cmd_callable
	var path_arr = parse_command_path(path)
	cmd.path = path
	cmd.path_arr = path_arr
	var result: String = _set_cmd(cmd, path_arr, overwrite)
	return result

func get_command(path: String):
	var path_arr = parse_command_path(path)
	return _get_cmd(path_arr)

func get_directory(path: String):
	var path_arr = parse_command_path(path)
	var dir = get_dir(path_arr)
	if dir == null:
		dir = {}
	return dir

func remove_command(path: String):
	var path_arr = parse_command_path(path)
	return _remove_cmd(path_arr)

func remove_path(path: String):
	var path_arr = parse_command_path(path)
	return _remove_path(path_arr)











func parse_command(input: String = ""):
	var type_split = input.split(" ", false, 2)
	var command_path_arr = type_split[0].split(".", false)
	var arg_path_arr = type_split[1].split(" ", false)
	return {"path": command_path_arr, "args": arg_path_arr}

func parse_command_path(input: String = "") -> Array:
	if input == "":
		return []
	var type_split = input.split(" ", false, 2)
	var psarr: PackedStringArray = type_split[0].split(".", false)
	var arr: Array = type_convert(psarr, TYPE_ARRAY)
	return arr


func parse_command_args(input: String = ""):
	var type_split = input.split(" ", false, 2)
	return " ".split(type_split[1])



"""
func read(path: Array[String]):
	return _recursive_read(path, commands)

func _recursive_read(path: Array[String], dict: Dictionary):
	var address: String = path.pop_front()
	var result = dict.get(address, null)
	if result == null or result is CommandReceiver:
		return result
	if result is Dictionary:
		_recursive_read(path, result)
"""
func print_dicts():
	for key in commands.keys():
		print(key,": ", commands[key])


func get_dir(path: Array, create_missing: bool = false, root_dict: Dictionary = commands):
	var current_dict: Dictionary = root_dict
	if path.size()- 1 < 1:
		return root_dict
	for i in range(path.size()-1):
		var key: String = path[i]
		if not current_dict.has(key):
			if create_missing == true:
				current_dict[key] = {}
			else:
				return null
		elif current_dict[key] is not Dictionary:
			return null
		current_dict = current_dict[key]
	return current_dict


func _get_cmd(path: Array):
	var directory = get_dir(path, false)
	if directory is not Dictionary:
		return null
	return directory.get(path.back(), null)


func _get_any(path: Array, create_missing: bool = false, root_dict: Dictionary = commands):
	var current: Dictionary = root_dict
	for i in range(path.size()):
		var key: String = path[i]
		if not current.has(key):
			if create_missing == true:
				current[key] = {}
			else:
				return null
		elif current[key] is not Dictionary:
			return current[key]
		current = current[key]
	return current


func _get_all_from(path: Array, root_dict: Dictionary = commands)-> Array:
	#var previous_path: Array = []
	var result: Array
	var current: Dictionary = root_dict
	for i in range(path.size()):
		var key: String = path[i]
		if current[key] is not Dictionary:
			return [key]
		if not current.has(key):
			return []

		current = current[key]
	for key in current.keys():
		result.append(key)
	return result


func _set_cmd(command: Command, path: Array, overwrite: bool = true):
	if command.callable.is_valid() == false:
		return "FAIL: Command.callable is not valid."
	var cmd_key = path.back()
	var dir = get_dir(path, true)
	if dir == null:
		return "FAIL: Directory fetch failed."
	if dir.has(cmd_key):
		if dir[cmd_key] is Dictionary:
			return "FAIL: Found directory at destination. Overwriting directories is not allowed."
		elif overwrite == false:
			return "FAIL: Found a non-directory variable (command) at destination. Overwrite was disabled so no changes were made."
		else:
			dir[cmd_key] = command
			return "SUCCESS: Found non-directory variable (command) at destination. Overwrite was enabled and old command was replaced."
	dir[cmd_key] = command
	return "SUCCESS: Directory fetch was successfull and command key was available. New command added."


func _remove_cmd(path: Array):
	var cmd_key = path.back()
	var cmd_dir = get_dir(path)
	if cmd_dir == null:
		return false
	if cmd_dir.has(cmd_key) == false:
		return false
	if cmd_dir[cmd_key] is Dictionary:
		return false
	cmd_dir.erase(cmd_key)
	return true


func _remove_path(path: Array):
	var cmd_key = path.back()
	var cmd_dir = get_dir(path)
	if cmd_dir == null:
		return false
	if cmd_dir.has(cmd_key) == false:
		return false
	cmd_dir.erase(cmd_key)
	return true


func erase(path: Array[String], delete_dicts: bool = false):
	if path.is_empty():
		return false
	_recursive_erase(path, commands, delete_dicts)


func _recursive_erase(path: Array[String], dict: Dictionary, delete_dicts = false):
	var address = path.pop_front()
	if path.is_empty():
		if delete_dicts or dict[address] is not Dictionary:
			dict[address].erase()
			return true
		else:
			return false
	if dict[address] is not Dictionary:
		return false
	return _recursive_erase(path, dict[address], delete_dicts)



func on_line_edit_update(text: String):
	get_suggestions(text)



func get_suggestions(text: String):
	var sugg_dict: Dictionary = _suggestion_parse(text)
	var result_dict: Dictionary = _search_path_from_sugg(sugg_dict)
	suggestion_list_update.emit(result_dict)


func _suggestion_parse(text: String):
	var result: Dictionary
	var parsed_input: Array = parse_command_path(text)
	result["path"] = parsed_input
	if text.ends_with("."):
		result["ends_with_point"] = true
	else:
		result["ends_with_point"] = false
	return result


func _search_path_from_sugg(sugg_dict: Dictionary, root_dict: Dictionary = commands)-> Dictionary:
	var path = sugg_dict["path"].duplicate()
	var options: Array
	var search_word: String = ""
	var return_dict: Dictionary = {"search_word": "", "options": []}
	print("Backend: _search_path_from_sugg: ", path)

	var current: Dictionary = root_dict
	var destination: Dictionary
	for i in range(path.size()):
		var key: String = path[i]
		if not current.has(key):
			destination = current
			search_word = key
			break
		if current.get(key) is not Dictionary:
			return_dict["options"] = [key]
			return return_dict
		current = current[key]
	if sugg_dict["ends_with_point"] == true:
		var results = destination.keys()
		results.sort_custom(func(a,b): return a.casecmp_to(b) < 0)
		return_dict["options"] = results
		return return_dict

	for key in destination.keys():
		if key.begins_with(search_word):
			options.append(key)
	if options.size() > 1:
		options.sort_custom(func(a,b): return a.casecmp_to(b) < 0)
	return_dict["search_word"] = search_word
	return_dict["options"] = options
	return return_dict
