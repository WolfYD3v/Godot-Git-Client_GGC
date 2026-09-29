@tool
extends VBoxContainer
class_name GGC_BranchItem

@export var branch_name: String = ""

@onready var branch_name_label: Label = $BranchNameLabel
@onready var delete_button: Button = $ActionsContainer/DeleteButton
@onready var switch_button: Button = $ActionsContainer/SwitchButton
@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

var currently_selected: bool = false
var stashing: bool = false



func _ready() -> void:
	var _name: String = branch_name.right(-2)
	if _name in ["main", "master"]: delete_button.queue_free()
	if branch_name_label: branch_name_label.text = _name
	
	print(branch_name)
	currently_selected = branch_name.begins_with("*")
	print(currently_selected)
	switch_button.disabled = currently_selected
	delete_button.disabled = currently_selected



func _on_switch_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["stash"])

func _on_delete_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["branch", "-D", branch_name_label.text])

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git stash":
			stashing = not(stashing)
			if stashing: ggc_execute_shell.execute("git", ["switch", branch_name_label.text])
		"git switch": ggc_execute_shell.execute("git", ["stash", "pop"])
		"git branch": pass
