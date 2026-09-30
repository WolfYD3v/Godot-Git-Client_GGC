@tool
extends Control
class_name GGC_Dashboard

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var ggc_error_window: GGC_ErrorWindow = $WindowsContainer/GGC_ErrorWindow
@onready var errors_count_label: Label = %ErrorsCountLabel
@onready var ggc_logs_menu: GGC_LogsMenu = %GGC_LogsMenu
@onready var ggc_branches_menu: GGC_BranchesMenu = %GGC_BranchesMenu

@onready var ggc_commiting_tool_window: GGC_CommitingToolWindow = $WindowsContainer/GGC_CommitingToolWindow
@onready var ggc_remote_tool_window: GGC_BaseWindow = $WindowsContainer/GGC_RemoteToolWindow

func _ready() -> void:
	ggc_error_window.dashboard = self
	ggc_commiting_tool_window.dashboard = self
	ggc_branches_menu.dashboard = self
	fire_git_branch_command()



func fire_git_log_command() -> void: ggc_execute_shell.execute("git", ["log", "--oneline"])

func fire_git_branch_command() -> void: ggc_execute_shell.execute("git", ["branch"])



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git branch":
			ggc_branches_menu.update_branches(ggc_execute_sheel_output.output)
			fire_git_log_command()
		"git log": ggc_logs_menu.update_logs(ggc_execute_sheel_output.output)
		_: pass



func _on_errors_button_pressed() -> void:
	ggc_error_window.popup()

func _on_commiting_tool_button_pressed() -> void:
	ggc_commiting_tool_window.popup()

func _on_remote_tool_button_pressed() -> void:
	ggc_remote_tool_window.popup()
