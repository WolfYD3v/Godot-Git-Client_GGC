@tool
extends GGC_BaseError
class_name GGC_GitNotInitError

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

var files_in_res: PackedStringArray = []

func _ready() -> void:
	super()
	check_git_init()

func check_git_init() -> void:
	var ls_cmd: Array = []
	match OS.get_name():
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD": ls_cmd = ["ls", ["-a"]]
		"macOS": ls_cmd = ["ls", ["-a"]]
		"Android": pass
		"Windows": ls_cmd = ["dir", ["-s"]]
		"iOS": pass
		"Web": pass
	ggc_execute_shell.execute(ls_cmd[0], ls_cmd[1])

func _on_init_git_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["init"])

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"ls a":
			files_in_res = ggc_execute_sheel_output.output[0].replace("\n", "|").split("|")
			var git_init: bool = ".git" in files_in_res
			set_display(not(git_init))
		_: check_git_init()
