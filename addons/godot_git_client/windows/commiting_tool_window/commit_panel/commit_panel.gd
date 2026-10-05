@tool
extends HBoxContainer
class_name GGC_CommitPanel

@onready var stage_files_list_container: VBoxContainer = $FilesContainer/StageFileContainer/Panel/MarginContainer/ScrollContainer/ListContainer
@onready var commit_files_list_container: VBoxContainer = $FilesContainer/FilesCommitingContainer/Panel/MarginContainer/ScrollContainer/ListContainer
@onready var use_commit_generic_name_button: Button = $CommitSettingsContainer/CommitNameSectionContainer/UseCommitGenericNameButton
@onready var commit_name_line_edit: LineEdit = $CommitSettingsContainer/CommitNameSectionContainer/Form/CommitNameLineEdit
@onready var commit_button: Button = $CommitSettingsContainer/CommitButton
@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

var commit_message: String = ""
var ggc_commiting_tool_window: GGC_CommitingToolWindow = null

func _ready() -> void:
	hide()



# It's a function, but written in a more fun way :)
var move_button = func(caller: Control):
	if caller.get_parent() == stage_files_list_container:
		caller.reparent(commit_files_list_container)
		update_commit_button_clickability()
		return
	if caller.get_parent() == commit_files_list_container:
		caller.reparent(stage_files_list_container)
		update_commit_button_clickability()
		return

func setup() -> void:
	update_commit_button_clickability()
	ggc_execute_shell.execute("git", ["status", "-s"])

func init_list_containers(new_content: Dictionary) -> void:
	# Clear the old children nodes in the list containers
	var old_nodes: Array[Node] = stage_files_list_container.get_children()
	old_nodes.append_array(commit_files_list_container.get_children())
	for _old_node: Control in old_nodes: _old_node.queue_free()
	
	# Add the new children nodes in the given list container
	var list_container: Control = null
	
	for _category: String in new_content.keys():
		list_container = get("%s_files_list_container" % _category)
		for _content in new_content.get(_category):
			var button: Button = Button.new()
			button.text = _content
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(move_button.bind(button))
			list_container.add_child(button)

func update_commit_button_clickability() -> void:
	commit_button.disabled = commit_files_list_container.get_child_count() <= 0

func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	return output

func update_ggc_commiting_tool_window_terminal(text: String, clear: bool = false, include_user: bool = true) -> void:
	if ggc_commiting_tool_window: ggc_commiting_tool_window.update_terminal(text, clear, include_user)

func close_panel() -> void:
	ggc_commiting_tool_window.toggle_panel(ggc_commiting_tool_window.PANELS.MAIN)
	commit_name_line_edit.text = ""



func _on_add_all_files_to_stage_button_pressed() -> void:
	for _button: Button in stage_files_list_container.get_children():
		_button.pressed.emit()

func _on_clear_files_to_stage_button_pressed() -> void:
	for _button: Button in commit_files_list_container.get_children():
		_button.pressed.emit()

func _on_use_commit_generic_name_button_pressed() -> void:
	var generic_commit_name: String = "Commit From %s" % [
		Time.get_datetime_string_from_system(false, true)
	]
	commit_name_line_edit.text = generic_commit_name

func _on_cancel_commit_button_pressed() -> void: close_panel()

func _on_commit_bis_button_pressed() -> void:
	ggc_commiting_tool_window.overlayere.show()
	if commit_name_line_edit.text == "": _on_use_commit_generic_name_button_pressed()
	commit_message = commit_name_line_edit.text
	
	var git_add_cmd_args: String = "add"
	var files_to_add: Array[String] = []
	for _button: Button in commit_files_list_container.get_children():
		var file_name: String = _button.text.substr(3)
		git_add_cmd_args += " %s" % file_name
		files_to_add.append(file_name)
	
	print("git %s" % git_add_cmd_args)
	print(git_add_cmd_args.split(" ", false))
	
	
	update_ggc_commiting_tool_window_terminal("git %s" % git_add_cmd_args, false, false)
	ggc_execute_shell.execute("git", git_add_cmd_args.split(" ", false))

func _on_commit_name_line_edit_text_changed(_new_text: String) -> void:
	update_commit_button_clickability()

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git status":
			update_ggc_commiting_tool_window_terminal("\n%s" % ggc_execute_sheel_output.output[0])
			var files: Dictionary[String, Array] = {
				"stage": cmd_output_to_array(ggc_execute_sheel_output.output[0]),
				"commit": []
			}
			init_list_containers(files)
		"git add":
			update_ggc_commiting_tool_window_terminal(ggc_execute_sheel_output.output[0])
			ggc_commiting_tool_window.overlayere.hide()
			close_panel()
			update_commit_button_clickability()
			update_ggc_commiting_tool_window_terminal('git commit -m "%s"' % commit_message, false, false)
			ggc_execute_shell.execute("git", ["commit", "-m", commit_message])
		"git commit":
			update_ggc_commiting_tool_window_terminal(ggc_execute_sheel_output.output[0])
			if ggc_commiting_tool_window.dashboard: ggc_commiting_tool_window.dashboard.fire_git_log_command()
		_: pass
