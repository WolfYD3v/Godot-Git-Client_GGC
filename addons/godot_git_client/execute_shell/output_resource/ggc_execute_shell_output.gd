extends Resource
class_name GGC_ExecuteSheelOutput

@export var output: Array = []
@export_range(0, 1, 1, "or_greater") var exit_code: int = 0
@export var action: String = ""
