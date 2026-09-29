@tool
extends GGC_BaseError
class_name GGC_GitNotFoundError

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

func _ready() -> void:
	super()
	look_for_git()

func look_for_git() -> void:
	ggc_execute_shell.execute("git", ["--version"])

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	var git_not_found: bool = ggc_execute_sheel_output.exit_code != ggc_execute_shell.ExitCode.SUCCESS
	set_display(git_not_found)

func _on_install_git_button_pressed() -> void:
	OS.shell_open("https://git-scm.com/install/".uri_encode())

func _on_look_for_git_button_pressed() -> void:
	look_for_git()
