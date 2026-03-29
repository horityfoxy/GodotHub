extends Node

@warning_ignore("unused_signal")
signal internet_allowed

const version : String = "1.0.0"
const SAVE_PATH = "user://installed_versions.json"

var _versions_data: Dictionary = {}
var _is_internet_allowed: bool = false

func _ready() -> void: 
	load_data()
	_cleanup_temp_archives()

# --- setters ---

func add_engine_version(version_id: String, executable_path: String, engine_name: String = "", icon_path: String = "") -> void:
	if not _versions_data.has(version_id): _versions_data[version_id] = {}
	if engine_name.is_empty(): engine_name = "Godot " + version_id
		
	_versions_data[version_id]["path"] = executable_path
	_versions_data[version_id]["name"] = engine_name
	_versions_data[version_id]["icon"] = icon_path
	
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

func get_engine_name(version_id: String) -> String:
	if _versions_data.has(version_id) and _versions_data[version_id].has("name"):
		return _versions_data[version_id]["name"]
	return "Godot " + version_id

func get_engine_icon(version_id: String) -> String:
	if _versions_data.has(version_id) and _versions_data[version_id].has("icon"):
		return _versions_data[version_id]["icon"]
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
			for v_key in _versions_data.keys():
				if not _versions_data[v_key].has("name"): _versions_data[v_key]["name"] = "Godot " + v_key
				if not _versions_data[v_key].has("icon"): _versions_data[v_key]["icon"] = ""
	else: print("Error parsing: ", json.get_error_message())

func remove_engine_folder_async(folder_name: String, progress_callback: Callable) -> void:
	var full_path: String = "user://engines/".path_join(folder_name)
	var files: Array[String] = []
	var dirs: Array[String] = []
	_collect_paths_recursive(full_path, files, dirs)
	dirs.append(full_path)
	dirs.sort_custom(func(a, b): return a.length() > b.length())
	
	var total_items = files.size() + dirs.size()
	if total_items == 0:
		if progress_callback.is_valid(): progress_callback.call(100.0)
		return
	var current_item = 0
	var batch_size = 30
	for f in files:
		DirAccess.remove_absolute(f)
		current_item += 1
		if current_item % batch_size == 0:
			if progress_callback.is_valid(): 
				progress_callback.call(float(current_item) / total_items * 100.0)
			await get_tree().process_frame
	
	for d in dirs:
		DirAccess.remove_absolute(d)
		current_item += 1
		if current_item % batch_size == 0:
			if progress_callback.is_valid(): 
				progress_callback.call(float(current_item) / total_items * 100.0)
			await get_tree().process_frame
			
	if progress_callback.is_valid(): 
		progress_callback.call(100.0)
	EventBus.godot_installed_version_changed.emit()

func _collect_paths_recursive(path: String, files: Array[String], dirs: Array[String]) -> void:
	var dir = DirAccess.open(path)
	if not dir: return
	dir.list_dir_begin()
	var item = dir.get_next()
	while item != "":
		if item != "." and item != "..":
			var item_path = path.path_join(item)
			if dir.current_is_dir():
				dirs.append(item_path)
				_collect_paths_recursive(item_path, files, dirs)
			else: files.append(item_path)
		item = dir.get_next()

func _cleanup_temp_archives() -> void:
	var path: String = "user://engines/"
	if not DirAccess.dir_exists_absolute(path): return
	var dir = DirAccess.open(path)
	if dir:
		var files = dir.get_files() 
		for file in files:
			if file.ends_with(".zip"):
				var err = dir.remove(file)
				if err != OK: printerr("ERROR: Can't remove temp archive: ", file)
				else: print("CLEANER: temp archive has remove: ", file)
