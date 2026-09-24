extends Resource
class_name Command

enum EXT{
	GET,#	Gets an extension from the given path. Can either return null, Dictionary or a CommandReceiver
	ADD,#	Creates an extension if the address is empty.
	SET,#	Creates or replaces an extension.
	ERASE,#	Erases an extension if the address is a CommandReceiver. Does nothing is the destination is another Dictionary
	CLEAR,#	Clears an extension address completely.
}


signal cmd_receiver_set
signal cmd_receiver_erased
signal cmd_receiver_replaced

signal cmd_signal_connected
signal cmd_signal_disconnected


signal ext_receiver_set
signal ext_receiver_replaced


@export_category("Command config")
@export var command_string_id: String
@export var enable_in_terminal: bool = true
@export var terminal_command: String
@export var use_string_id_as_terminal_command: bool = true
@export var extensions: Array[String]
var source_id:= "ConsoleCommand: " + " '" +command_string_id +"'"


var cmd_receiver: CommandReceiver
var ext_receivers: Dictionary

############################## API ############################################################ API ############################################################ API ##############################

###################### CMD ###################### 

func _ready():
	pass


func run_cmd(args: Array):
	pass


func set_cmd_callable(callable: Callable):
	var receiver = _create_receiver(callable, CommandReceiver.Type.CMD)
	_set_cmd_receiver(receiver)

func erase_cmd_callable():
	_erase_cmd_receiver()

	
func connect_cmd_signal(callable: Callable):
	if !cmd_receiver.is_valid():
		return
	cmd_receiver.cmd_executed.connect(callable)
	cmd_signal_connected.emit()


###################### EXT ######################

func run_ext(path: Array, args: Array):
	var receiver = get_ext(path)
	if receiver and receiver.callable.is_valid():
		receiver.callable.callv(args)
		receiver.ext_executed.emit()

func run_ext_str(path: String, ...args):
	var path_arr: Array = Ses.console.format_ext_path_string(path)
	pass

func get_ext(path: Array):
	return _ext_fetch(ext_receivers, path)


func _ext_path_str_to_arr(input: String):
	var packed_string_array: PackedStringArray = input.split(".", false)
	var result: Array = Array(packed_string_array)
	return result

func set_ext(callable, ext_name: String, ...args: Array):
	var receiver = _create_receiver(callable, CommandReceiver.Type.EXT)
	var final_path: Array[String]
	if args.is_empty():
		final_path =  _set_ext_receiver(ext_receivers, receiver, [ext_name])
	else:
		var arr = [ext_name]+args
		final_path = _set_ext_receiver(ext_receivers, receiver, arr)
	receiver.ext_path = final_path
	ext_receiver_set.emit(final_path)
	return final_path

func erase_ext_receiver(...path):
	_erase_ext_receiver_wrapper(path, false)

func erase_ext_address(...path):
	_erase_ext_receiver_wrapper(path, true)

func connect_ext_signal(callable: Callable, ...path):
	var fetched_ext = _ext_fetch(ext_receivers, path)
	if fetched_ext is CommandReceiver:
		fetched_ext.ext_executed.connect(callable)

###################################################################################################################################################################################################


func _ext_fetch(dict: Dictionary, path: Array[String]):
	var address = path.pop_front()
	if path.is_empty():
		return dict.get(address, null)
	if dict[address] is Dictionary:
		return _ext_fetch(dict[address], path)
	if dict[address] is Callable:
		return dict[address]
	else:
		Ses._shit_pants("class: Command, function: _ext_fetch() - ext_receivers -dictionary has a value that is neither Dictionary or Callable")


func _set_ext_receiver(dict: Dictionary, receiver: CommandReceiver, ext_keys: Array, current_path: Array = []):
	var ext_key = ext_keys.pop_front()
	if ext_keys.is_empty():
		dict[ext_key] = receiver
		current_path.append(ext_key)
		return current_path
	else:
		current_path.append(ext_key)
		var new_dict: Dictionary
		if dict[ext_key] and dict[ext_key] is Dictionary:
			new_dict = dict[ext_key]
		elif dict[ext_key]:
			push_error("Command._set_ext_receiver: Path '",current_path, "' is already reserver for a receiver.")
			return null
		return _set_ext_receiver(new_dict, receiver, ext_keys, current_path)


func _erase_ext_receiver_wrapper(path: Array, erase_folders: bool = false):
	var result: bool = _erase_ext_receiver(ext_receivers, path, erase_folders)
	if result == true:
		_ext_erase_dict_if_empty(path)

func _erase_ext_receiver(dict: Dictionary, ext_keys: Array, erase_folders: bool = false):
	var ext_key = ext_keys.pop_front()
	if !dict[ext_key]:
		return false
	if dict[ext_key] is Callable:
		dict[ext_key].erase()
		return true
	if ext_keys.is_empty():
		if dict[ext_key] is Dictionary and erase_folders == true:
			dict[ext_key].erase()
			return true
		else:
			return false
	if dict[ext_key] is Dictionary:
		return _erase_ext_receiver(dict[ext_key], ext_keys)
	Ses._shit_pants("Stop putting variables that aren't Dictionary or Callable to the ext_receivers array! Stupid fuck...")


func _on_ext_exit(...path):
	_erase_ext_receiver_wrapper(path, false)

func _ext_erase_dict_if_empty(path: Array[String]):
	path.pop_back()
	var ext = get_ext(path)
	if ext is Dictionary and ext.is_empty():
		ext.erase()

func _set_cmd_receiver(r: CommandReceiver):
	if !cmd_receiver:
		cmd_receiver = r
	else:
		cmd_receiver = r
		cmd_receiver_replaced.emit()
	_connect_receiver_exit(cmd_receiver, _on_cmd_receiver_exit)
	cmd_receiver_set.emit()

func _erase_cmd_receiver():
	cmd_receiver = null
	cmd_receiver_erased.emit()
	cmd_signal_disconnected.emit()

func _on_cmd_receiver_exit(receiver_node_id):
	if cmd_receiver and cmd_receiver.node_id == receiver_node_id:
		cmd_receiver = null

func _create_receiver(callable: Callable, type: CommandReceiver.Type):
	var receiver = CommandReceiver.new()
	receiver.selected_type = type
	var parent_obj = callable.get_object()
	if parent_obj is not Node:
		push_error("AAAAAAAAAAAA")
	var node_id: int = parent_obj.get_instance_id()
	receiver.node_id = node_id
	receiver.callable = callable
	return receiver


func _connect_receiver_exit(receiver: CommandReceiver, callable: Callable):
	if receiver.callable.is_valid() == false:
		return
	var parent_obj = receiver.callable.get_object()
	if parent_obj is not Node:
		return
	var node_id = receiver.node_id
	parent_obj.tree_exited.connect(callable).bind(node_id)
