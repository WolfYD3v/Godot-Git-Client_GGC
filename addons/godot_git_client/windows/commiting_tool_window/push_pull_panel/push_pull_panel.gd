@tool
extends VBoxContainer
class_name GGC_PushPullPanel

enum ACTION {
	PUSH,
	PULL
}

@onready var remote_selector_option_button: OptionButton = %RemoteSelectorOptionButton
@onready var branch_selector_option_button: OptionButton = %BranchSelectorOptionButton
@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var force_check_button: CheckButton = %ForceCheckButton
@onready var action_button: Button = %ActionButton

var ggc_commiting_tool_window: GGC_CommitingToolWindow = null
var current_remote_selected: String = ""
var current_branch_selected: String = ""

func _ready() -> void:
	hide()



func setup() -> void: ggc_execute_shell.execute("git", ["remote", "-v"])

func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	return output

func init_option_button(option_button: OptionButton, value: PackedStringArray) -> void:
	option_button.clear()
	
	for idx: int in range(len(value)):
		var y = value[idx]
		option_button.add_item(y)

func update_ggc_commiting_tool_window_terminal(text: String, clear: bool = false, include_user: bool = true) -> void:
	if ggc_commiting_tool_window: ggc_commiting_tool_window.update_terminal(text, clear, include_user)

func set_action(action: ACTION) -> void:
	force_check_button.disabled = action == ACTION.PULL
	if action_button.is_connected("pressed", fire_push_command): action_button.pressed.disconnect(fire_push_command)
	if action_button.is_connected("pressed", fire_pull_command): action_button.pressed.disconnect(fire_pull_command)
	
	match action:
		ACTION.PUSH:
			action_button.text = "Push"
			action_button.pressed.connect(fire_push_command)
		ACTION.PULL:
			action_button.text = "Pull"
			action_button.pressed.connect(fire_pull_command)

func fire_push_command() -> void:
	if current_remote_selected == "": current_remote_selected = remote_selector_option_button.get_item_text(0)
	if current_branch_selected == "": current_branch_selected = branch_selector_option_button.get_item_text(0)
	update_ggc_commiting_tool_window_terminal("git push %s %s" % [
		current_remote_selected, current_branch_selected
	])
	ggc_execute_shell.execute("git", ["push", current_remote_selected, current_branch_selected])

func fire_pull_command() -> void:
	if current_remote_selected == "": current_remote_selected = remote_selector_option_button.get_item_text(0)
	if current_branch_selected == "": current_branch_selected = branch_selector_option_button.get_item_text(0)
	update_ggc_commiting_tool_window_terminal("git pull %s %s" % [
		current_remote_selected, current_branch_selected
	])
	#ggc_execute_shell.execute("git", ["pull", current_remote_selected, current_branch_selected])



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git remote":
			var temp_remotes_array: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			var real_remotes_array: PackedStringArray = []
			for _remote: String in temp_remotes_array:
				var remote = _remote.split("\t")[0]
				if not remote in real_remotes_array: real_remotes_array.append(remote)
			init_option_button.call_deferred(remote_selector_option_button, real_remotes_array)
			ggc_execute_shell.execute("git", ["branch"])
		"git branch":
			var temp_branches_array: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			var real_branches_array: PackedStringArray = []
			for _branch: String in temp_branches_array: real_branches_array.append(_branch.right(-2))
			init_option_button.call_deferred(branch_selector_option_button, real_branches_array)
		"git push": update_ggc_commiting_tool_window_terminal(ggc_execute_sheel_output.output[0], false, false)
		"git pull": update_ggc_commiting_tool_window_terminal(ggc_execute_sheel_output.output[0], false, false)
		_: pass


func _on_close_button_pressed() -> void:
	if ggc_commiting_tool_window: ggc_commiting_tool_window.toggle_panel(
		ggc_commiting_tool_window.PANELS.MAIN
	)
	force_check_button.button_pressed = false

func _on_remote_selector_option_button_item_selected(index: int) -> void:
	print(index)
	current_remote_selected = remote_selector_option_button.get_item_text(index)
	print(current_remote_selected)

func _on_branch_selector_option_button_item_selected(index: int) -> void:
	print(index)
	current_branch_selected = branch_selector_option_button.get_item_text(index)
	print(current_branch_selected)
