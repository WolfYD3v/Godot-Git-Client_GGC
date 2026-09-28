@tool
extends Node
class_name GGC_Execute_Shell

signal execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput)

@export var read_stderr: bool = true

enum ExitCode {
	SUCCESS      = 0,
	FAILURE      = 1,
	GIT_NOT_INIT = 128
}

var thread: Thread = null
var current_action: String = ""

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if thread and thread.is_alive(): thread.wait_to_finish()

func execute(path: String, arguments: PackedStringArray = []) -> void:
	if arguments.size() >= 1: set_current_action(path, arguments[0])
	else: set_current_action("", "")

	thread = Thread.new()
	thread.start(_run_command.bind(path, arguments))

func set_current_action(path: String, action_name: String) -> void:
	for char_to_replace: String in ["-"]:
		action_name = action_name.replace(char_to_replace, "")
	
	current_action = "%s %s" % [path, action_name]

func get_current_action() -> String:
	var action: String = current_action
	return action

func _run_command(path: String, arguments: PackedStringArray) -> void:
	var output: Array = []
	var exit_code: int = OS.execute(path, arguments, output, read_stderr)
	if is_instance_valid(self): execution_finished.call_deferred(exit_code, output)

func execution_finished(exit_code: int, output: Array) -> void:
	if thread and thread.is_started(): thread.wait_to_finish()
	
	var action_name: String = current_action
	current_action = ""
	var ggc_execute_sheel_output: GGC_ExecuteSheelOutput = GGC_ExecuteSheelOutput.new()
	ggc_execute_sheel_output.output = output
	ggc_execute_sheel_output.exit_code = exit_code
	ggc_execute_sheel_output.action = action_name
	
	execution_done.emit(ggc_execute_sheel_output)
