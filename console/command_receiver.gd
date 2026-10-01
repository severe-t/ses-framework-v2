extends RefCounted
class_name CommandReceiver

var node_id: int
var callable: Callable

signal executed

func execute(args: Array):
	Ses.auto_match_arr(callable, args)#	Ei vittu varmana toimi
	executed.emit(args)