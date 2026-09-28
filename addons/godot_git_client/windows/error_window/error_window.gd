@tool
extends GGC_BaseWindow
class_name GGC_ErrorWindow

@onready var errors: VBoxContainer = $VBoxContainer/Interface/MarginContainer/ErrorsScrollContainer/Errors

func _ready() -> void:
	super()
	var action_popup = popup
	var action_close = close
	errors.pre_sort_children.connect(trigger_dashboard_errors_count_update)
	errors.sort_children.connect(trigger_dashboard_errors_count_update)
	for _error: GGC_BaseError in errors.get_children(): _error.visibility_changed.connect(trigger_dashboard_errors_count_update)

func create_error(error_path: String) -> void:
	var packed_scene: PackedScene = load(error_path)
	var new_error: GGC_BaseError = packed_scene.instantiate()
	new_error.visibility_changed.connect(trigger_dashboard_errors_count_update)
	errors.add_child(new_error)

func trigger_dashboard_errors_count_update() -> void:
	var active_errors_count: int = 0
	for _error: GGC_BaseError in errors.get_children():
		if _error.visible: active_errors_count += 1
	
	dashboard.errors_count_label.text = str(active_errors_count)
