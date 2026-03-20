extends Node

@warning_ignore("unused_signal")
signal internet_allowed

const version : String = "0.8.2"
const SAVE_PATH = "user://installed_versions.json"

var _versions_data: Dictionary = {}
var _is_internet_allowed: bool = false

func _ready() -> void: load_data()

# --- setters ---

func set_godot_path(version_name: String, executable_path: String) -> void:
	if not _versions_data.has(version_name): _versions_data[version_name] = {}
	_versions_data[version_name]["path"] = executable_path
	EventBus.godot_installed_version_changed.emit()
	save_data()

func set_internet_allowed(value: bool) -> void:
	_is_internet_allowed = value
	internet_allowed.emit()
	save_data()

# --- getters ---

func is_internet_allowed() -> bool: return _is_internet_allowed

func get_sorted_versions() -> Array:
	var versions = _versions_data.keys()
	versions.sort_custom(_compare_versions_strings)
	return versions

func _compare_versions_strings(a: String, b: String) -> bool:
	var v1 = _version_to_int_array(a)
	var v2 = _version_to_int_array(b)
	for i in range(min(v1.size(), v2.size())):
		if v1[i] > v2[i]: return true 
		if v1[i] < v2[i]: return false 
	return v1.size() > v2.size()

func _version_to_int_array(v_str: String) -> Array:
	var clean = v_str.get_slice("-", 0).replace("v", "")
	var parts = clean.split(".")
	var ints = []
	for p in parts:
		if p.is_valid_int(): ints.append(p.to_int())
	return ints

func get_godot_path(version_name: String) -> String:
	if _versions_data.has(version_name) and _versions_data[version_name].has("path"):
		return _versions_data[version_name]["path"]
	return ""

func get_all_versions() -> Array: return _versions_data.keys()

func save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("Error: can't make save file")
		return
	
	var data_to_save = {
		"is_internet_allowed": _is_internet_allowed,
		"versions": _versions_data
	}
	
	var json_string = JSON.stringify(data_to_save, "\t")
	file.store_string(json_string)
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result == OK:
		var root_data = json.get_data()
		if root_data is Dictionary:
			_is_internet_allowed = root_data.get("is_internet_allowed", false)
			_versions_data = root_data.get("versions", {})
	else:
		print("Error parsing: ", json.get_error_message())

func remove_engine_folder(folder_name: String) -> int:
	EventBus.godot_installed_version_changed.emit()
	var full_path: String = "user://engines/".path_join(folder_name)
	var dir = DirAccess.open(full_path)
	if not dir: return ERR_CANT_OPEN 
	dir.list_dir_begin()
	var item = dir.get_next()
	while item != "":
		if item != "." and item != "..":
			if dir.current_is_dir():
				var res = remove_engine_folder(folder_name.path_join(item))
				if res != OK: return res
			else:
				var res = dir.remove(item)
				if res != OK: return res
		item = dir.get_next()
	dir = null
	return DirAccess.remove_absolute(full_path)
