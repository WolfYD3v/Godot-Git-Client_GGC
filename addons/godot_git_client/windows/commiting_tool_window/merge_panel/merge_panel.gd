@tool
extends VBoxContainer
class_name GGC_MergePanel

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var merge_branch_option_button: OptionButton = %MergeBranchOptionButton
@onready var current_branch_name_label: Label = %CurrentBranchNameLabel
@onready var merge_button: Button = %MergeButton

var ggc_commiting_tool_window: GGC_CommitingToolWindow = null
var current_branch: String = ""

func _ready() -> void:
	hide()
	
	setup()
	show()



func setup() -> void: ggc_execute_shell.execute("git", ["branch"])

func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	return output

func init_option_button(option_button: OptionButton, value: PackedStringArray) -> void:
	option_button.clear()
	
	for idx: int in range(len(value)):
		var y = value[idx]
		option_button.add_item(y)

func set_current_branch_name() -> void: current_branch_name_label.text = current_branch

func update_ggc_commiting_tool_window_terminal(text: String, clear: bool = false, include_user: bool = true) -> void:
	if ggc_commiting_tool_window: ggc_commiting_tool_window.update_terminal(text, clear, include_user)

func close_panel() -> void:
	if ggc_commiting_tool_window:
		ggc_commiting_tool_window.toggle_panel(
			ggc_commiting_tool_window.PANELS.MAIN
		)
		ggc_commiting_tool_window.overlayere.hide()



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git branch":
			var temp_branches_array: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			var real_branches_array: PackedStringArray = []
			for _branch: String in temp_branches_array:
				var branch = _branch.split("\t")[0]
				if branch.begins_with("*"): current_branch = branch.right(-2)
				else:
					var branch_name: String = branch.right(-2)
					if not branch_name in real_branches_array: real_branches_array.append(branch_name)
			print(real_branches_array)
			print(current_branch)
			
			init_option_button(merge_branch_option_button, real_branches_array)
			set_current_branch_name()
			merge_button.disabled = merge_branch_option_button.item_count <= 0
		_: pass


func _on_close_button_pressed() -> void:
	close_panel()
