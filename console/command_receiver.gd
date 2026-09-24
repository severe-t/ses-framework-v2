extends RefCounted
class_name CommandReceiver
enum Type{
	CMD,
	EXT,
}
var selected_type: Type
var node_id: int
var callable: Callable

var ext_path: Array[String]

signal cmd_executed
signal ext_executed

func execute(args: Array):
	Ses.auto_match_arr(callable, args)#	Ei vittu varmana toimi
	match selected_type:
		Type.CMD:
			cmd_executed.emit(args)
		Type.EXT:
			ext_executed.emit(args)