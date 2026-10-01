@tool
extends Control
class_name GGC_BranchesTree

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

var branches: Array[String] = []
var current_branch: String = ""
var tree: Dictionary = {}


func _ready() -> void:
	ggc_execute_shell.execute("git", ["branch"])



func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	return cmd_output.split("\n", false)

func clean_logs(logs: PackedStringArray) -> PackedStringArray:
	var new_logs: PackedStringArray = []
	for log: String in logs: new_logs.append(log.right(-8))
	new_logs.reverse()
	
	return new_logs

func get_logs_from_branches() -> void:
	for branch: String in branches:
		current_branch = branch
		ggc_execute_shell.execute("git", ["log", branch, "--oneline"])
		await ggc_execute_shell.execution_done
	
	# print(tree)
	print(get_texted_tree())

func look_for_rupture_points() -> Dictionary:
	var rupture_points: Dictionary = {}
	var max_scan_size: int = 0
	
	# Get the maximum size of an Array, from all the Arrays in the tree
	for branch: String in tree.keys():
		var logs: Array = tree.get(branch)
		if logs.size() > max_scan_size: max_scan_size = logs.size()
	print("Max Scan Size - %s" % max_scan_size)
	
	# Get the rupture points
	for array_idx: int in range(max_scan_size):
		for branch: String in tree.keys():
			var log: String = ""
			var previous_log: String = ""
			var logs: Array = tree.get(branch)
			if max_scan_size <= logs.size(): log = logs.get(array_idx)
			else: log = ""
			
			print("%s - %s" % [branch, log])
	print(rupture_points)
	
	return rupture_points

func get_texted_tree() -> String:
	var texted_tree: String = ""
	var rupture_points: Dictionary = look_for_rupture_points()
	
	for branch: String in tree.keys():
		texted_tree += "[ %s ]\t" % branch
		for log: String in tree.get(branch): texted_tree += " %s\t" % log
		texted_tree += "\n\n"
	
	return texted_tree



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git branch":
			tree = {}
			branches = []
			var all_branches: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			for branch: String in all_branches: branches.append(branch.right(-2))
			get_logs_from_branches()
		"git log":
			var logs: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			tree[current_branch] = clean_logs(logs)
