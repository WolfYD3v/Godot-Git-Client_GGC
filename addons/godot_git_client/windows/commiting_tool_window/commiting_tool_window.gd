@tool
extends GGC_BaseWindow
class_name GGC_CommitingToolWindow

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var terminal: CodeEdit = $VBoxContainer/Interface/MarginContainer/Main/TerminalContainer/TerminalPanel/MarginContainer/Terminal
@onready var main: HBoxContainer = $VBoxContainer/Interface/MarginContainer/Main
@onready var commit: HBoxContainer = $VBoxContainer/Interface/MarginContainer/Commit
@onready var stage_files_list_container: VBoxContainer = $VBoxContainer/Interface/MarginContainer/Commit/FilesContainer/StageFileContainer/Panel/MarginContainer/ScrollContainer/ListContainer
@onready var commit_files_list_container: VBoxContainer = $VBoxContainer/Interface/MarginContainer/Commit/FilesContainer/FilesCommitingContainer/Panel/MarginContainer/ScrollContainer/ListContainer
@onready var use_commit_generic_name_button: Button = $VBoxContainer/Interface/MarginContainer/Commit/CommitSettingsContainer/CommitNameSectionContainer/UseCommitGenericNameButton
@onready var commit_name_line_edit: LineEdit = $VBoxContainer/Interface/MarginContainer/Commit/CommitSettingsContainer/CommitNameSectionContainer/Form/CommitNameLineEdit
@onready var commit_button: Button = $VBoxContainer/Interface/MarginContainer/Commit/CommitSettingsContainer/CommitButton
@onready var overlayere: ColorRect = $VBoxContainer/Interface/Overlayere

@export var logging: bool = true

const TERMINAL_LOGS_FILE_PATH: String = "res://addons/godot_git_client/windows/commiting_tool_window/terminal_logs.txt"

var commit_message: String = ""

func _ready() -> void:
	super()
	overlayere.hide()
	var action_popup = popup
	var action_close = close
	main.show()
	commit.hide()
	_on_cancel_commit_button_pressed()
	update_commit_button_clickability()
	
	if logging:
		if not FileAccess.file_exists(TERMINAL_LOGS_FILE_PATH): write_terminal_logs()
		load_terminal_logs()
	else: init_terminal()




func init_terminal() -> void:
	terminal.text = "user: "

func update_terminal(text: String, clear: bool = false, include_user: bool = true) -> void:
	if clear: init_terminal()
	terminal.text += "%s\n" % text
	if include_user: terminal.text += "user: "
	
	if logging: write_terminal_logs()

func write_terminal_logs() -> void:
	var file = FileAccess.open(TERMINAL_LOGS_FILE_PATH, FileAccess.WRITE)
	if not file: return
	
	file.store_string(terminal.text)
	file.close()

func load_terminal_logs() -> void:
	var file = FileAccess.open(TERMINAL_LOGS_FILE_PATH, FileAccess.READ)
	if not file: return
	
	terminal.text = file.get_as_text()
	file.close()

func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	
	return output

var a = func(caller: Control):
	if caller.get_parent() == stage_files_list_container:
		caller.reparent(commit_files_list_container)
		update_commit_button_clickability()
		return
	if caller.get_parent() == commit_files_list_container:
		caller.reparent(stage_files_list_container)
		update_commit_button_clickability()
		return

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
			button.pressed.connect(a.bind(button))
			list_container.add_child(button)

func update_commit_button_clickability() -> void:
	commit_button.disabled = commit_files_list_container.get_child_count() <= 0



func _on_clear_button_pressed() -> void:
	init_terminal()

func _on_status_button_pressed() -> void:
	update_terminal("git status", false, false)
	ggc_execute_shell.execute("git", ["status"])

func _on_diff_button_pressed() -> void:
	update_terminal("git diff", false, false)
	ggc_execute_shell.execute("git", ["diff"])

func _on_commit_button_pressed() -> void:
	main.hide()
	commit.show()
	update_commit_button_clickability()
	
	ggc_execute_shell.execute("git", ["status", "-s"])

func _on_push_button_pressed() -> void:
	update_terminal("git push", false, true)
	# ggc_execute_shell.execute("git", ["push"])

func _on_pull_button_pressed() -> void:
	update_terminal("git pull", false, true)
	# ggc_execute_shell.execute("git", ["pull"])

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

func _on_cancel_commit_button_pressed() -> void:
	main.show()
	commit.hide()
	commit_name_line_edit.text = ""

func _on_commit_name_line_edit_text_changed(_new_text: String) -> void:
	update_commit_button_clickability()

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git diff": update_terminal(ggc_execute_sheel_output.output[0], false)
		"git add":
			update_terminal(ggc_execute_sheel_output.output[0], false)
			overlayere.hide()
			_on_cancel_commit_button_pressed()
			update_commit_button_clickability()
			update_terminal('git commit -m "%s"' % commit_message, false, false)
			ggc_execute_shell.execute("git", ["commit", "-m", commit_message])
		"git commit":
			update_terminal(ggc_execute_sheel_output.output[0])
			if dashboard: dashboard.fire_git_log_command()
			#
		"git status":
			update_terminal(ggc_execute_sheel_output.output[0], false)
			var files: Dictionary[String, Array] = {
				"stage": cmd_output_to_array(ggc_execute_sheel_output.output[0]),
				"commit": []
			}
			init_list_containers(files)


func _on_restore_button_pressed() -> void:
	pass


func _on_commit_bis_button_pressed() -> void:
	overlayere.show()
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
	
	
	update_terminal("git %s" % git_add_cmd_args, false, false)
	ggc_execute_shell.execute("git", git_add_cmd_args.split(" ", false))
