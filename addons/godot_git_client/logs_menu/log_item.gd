@tool
extends Label
class_name GGC_LogItem

func _ready() -> void:
	name = "GGC_LogItem"
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
