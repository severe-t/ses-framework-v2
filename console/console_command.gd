extends Resource
class_name Command

var callable: Callable :
	set(value): 
		callable = value
		update_callable(value)

var parent_node_id: int
var source_id:= "ConsoleCommand"
var parent_source_id: String = "Unknown"


# |
#\|/	For exported commands. Not used during runtime
# v
var placeholder_path: String = "UNKNOWN_PATH"

var path: String = placeholder_path
var path_arr: Array
var description: String

signal command_executed
signal callable_updated
signal receiver_exit
signal signal_connected
#signal signal_disconnected

#	Possible things to do:
#	Signal listing
#	Signal disconnect signal


func _ready():
	callable = placeholder_callable()

func placeholder_callable():
	Ses.out(self, Color.WHITE, path, ": No callable connected.")

func update_callable(new_callable: Callable):
	if new_callable == placeholder_callable:
		return
	var parent_obj = new_callable.get_object()
	if not (parent_obj is Node):
		push_error("AAAAAAAAAAAA")
	var parent_node: Node = parent_obj as Node
	parent_node_id = parent_node.get_instance_id()
	if "source_id" in parent_node:
		parent_source_id = parent_node.source_id
	parent_node.tree_exited.connect(on_source_exit)
	callable_updated.emit()


func connect_signal(receiver_callable):
	command_executed.connect(receiver_callable)
	signal_connected.emit()


func execute(...args):
	Ses.varcon.auto_match_arr(callable, args)
	command_executed.emit(args)


func on_source_exit():
	callable = placeholder_callable
	receiver_exit.emit()


func get_path_as_arr():
	if path == placeholder_path:
		push_error()
	return Array(".".split(path, false))
