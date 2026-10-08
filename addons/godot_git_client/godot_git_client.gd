@tool
extends EditorPlugin

var ggc_window: Window = null
var ggc_action_name: String = "Godot Git Client"
var ggc_dashboard_packed_scene: PackedScene = preload(
	"res://addons/godot_git_client/dashboard/dashboard.tscn"
)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_G):
			_open_ggc_window()

func _enter_tree() -> void:
	add_tool_menu_item(ggc_action_name, _open_ggc_window)

func _open_ggc_window() -> void:
	# Create the GGC Window
	ggc_window = Window.new()
	ggc_window.title = ggc_action_name
	ggc_window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	ggc_window.size = get_viewport().get_window().size
	ggc_window.minimize_disabled = true
	ggc_window.unresizable = true
	ggc_window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	ggc_window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	ggc_window.grab_focus()
	EditorInterface.get_base_control().add_child(ggc_window)
	
	# Load the interface
	ggc_window.add_child(ggc_dashboard_packed_scene.instantiate())
	
	# To close the window without issues
	ggc_window.close_requested.connect(
		func(): ggc_window.queue_free()
	)
	
	# Show the window
	ggc_window.popup_centered()

func _exit_tree() -> void:
	remove_tool_menu_item(ggc_action_name)
	if ggc_window: ggc_window.queue_free()
