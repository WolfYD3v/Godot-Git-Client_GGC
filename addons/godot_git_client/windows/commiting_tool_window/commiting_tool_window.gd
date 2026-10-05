@tool
extends GGC_BaseWindow
class_name GGC_CommitingToolWindow

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var terminal: CodeEdit = $VBoxContainer/Interface/MarginContainer/Main/TerminalContainer/TerminalPanel/MarginContainer/Terminal
@onready var main: HBoxContainer = $VBoxContainer/Interface/MarginContainer/Main
@onready var commit_panel: GGC_CommitPanel = $VBoxContainer/Interface/MarginContainer/CommitPanel
@onready var overlayere: ColorRect = $VBoxContainer/Interface/Overlayere

@export var logging: bool = true

const TERMINAL_LOGS_FILE_PATH: String = "res://addons/godot_git_client/windows/commiting_tool_window/terminal_logs.txt"

func _ready() -> void:
	super()
	var action_popup = popup
	var action_close = close
	commit_panel.ggc_commiting_tool_window = self
	overlayere.hide()
	main.show()
	
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
	commit_panel.show()
	commit_panel.setup()

func _on_push_button_pressed() -> void:
	# update_terminal("git push", false, true)
	# ggc_execute_shell.execute("git", ["push"])
	pass

func _on_pull_button_pressed() -> void:
	# update_terminal("git pull", false, true)
	# ggc_execute_shell.execute("git", ["pull"])
	pass

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git diff": update_terminal(ggc_execute_sheel_output.output[0], false)
		"git status": update_terminal(ggc_execute_sheel_output.output[0], false)


func _on_restore_button_pressed() -> void:
	pass
