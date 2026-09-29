@tool
extends GGC_BaseError
class_name GGC_NoOriginFoundError

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

func _ready() -> void:
	super()
	ggc_execute_shell.execute("git", ["remote", "-v"])



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git remote": set_display(ggc_execute_sheel_output.output[0] == "")
		_: pass

func _on_add_origin_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["remote", "-v"])
