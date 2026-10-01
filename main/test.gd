extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_add_commands()
#	test_get_commands()
	#test_erase_commands()
#	test_erase_any()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var added_path_a: String = "yykeri.kaakeri.kookeri"
var added_path_b: String = "yykeri.kookeri.kaakeri"
var added_path_c: String = "kaakeri.yykeri.kookeri"
var added_path_d: String = "kaakeri.kookeri.yykeri"

var get_cmd_a: String = "a.a.a"
var get_cmd_b: String = "a.a.b"
var get_cmd_c: String = "b.b.c"
var get_cmd_d: String = "a.b.b"

var remove_cmd_a: String = "a.a.a"
var remove_cmd_b: String = "a.a.b"
var remove_cmd_c: String = "b.b"
var remove_cmd_d: String = "a.b.b"

var remove_dir_a: String = "a.a.a"
var remove_dir_b: String = "a.a.c"
var remove_dir_c: String = "b"
var remove_dir_d: String = "b.b.b"

func test_function_a():
	Ses.out(self, Color.WHITE, "Test A!")
	return true

func test_function_b():
	Ses.out(self, Color.WHITE, "Test B!")
	return true

func test_function_c():
	Ses.out(self, Color.WHITE, "Test C!")
	return true

func test_function_d():
	Ses.out(self, Color.WHITE, "Test D!")
	return true


func test_add_commands():
	print("Add commands:")
	var result_a = Ses.console.backend.add_command(added_path_a, test_function_a, false)
	var result_b = Ses.console.backend.add_command(added_path_b, test_function_b, true)
	var result_c = Ses.console.backend.add_command(added_path_c, test_function_c, false)
	var result_d = Ses.console.backend.add_command(added_path_d, test_function_c, true)

	print("Result A:", result_a)
	print("Result B:", result_b)
	print("Result C:", result_c)
	print("Result D:", result_d)
	Ses.console.backend.print_dicts()

func test_get_commands():
	print("Get commands:")
	var result_a = Ses.console.backend.get_command(get_cmd_a)
	var result_b = Ses.console.backend.get_command(get_cmd_b)
	var result_c = Ses.console.backend.get_command(get_cmd_c)
	var result_d = Ses.console.backend.get_command(get_cmd_d)
	print("Result A:", result_a)
	print("Result B:", result_b)
	print("Result C:", result_c)
	print("Result D:", result_d)
	Ses.console.backend.print_dicts()

func test_erase_commands():
	print("Remove commands:")
	var result_a = Ses.console.backend.remove_command(remove_cmd_a)
	var result_b = Ses.console.backend.remove_command(remove_cmd_b)
	var result_c = Ses.console.backend.remove_command(remove_cmd_c)
	var result_d = Ses.console.backend.remove_command(remove_cmd_d)
	print("Result A:", result_a)
	print("Result B:", result_b)
	print("Result C:", result_c)
	print("Result D:", result_d)
	Ses.console.backend.print_dicts()

func test_erase_any():
	print("Remove any:")
	var result_a = Ses.console.backend.remove_path(remove_dir_a)
	var result_b = Ses.console.backend.remove_path(remove_dir_b)
	var result_c = Ses.console.backend.remove_path(remove_dir_c)
	var result_d = Ses.console.backend.remove_path(remove_dir_d)
	print("Result A:", result_a)
	print("Result B:", result_b)
	print("Result C:", result_c)
	print("Result D:", result_d)
	Ses.console.backend.print_dicts()