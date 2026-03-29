extends Node

const SAVE_PATH = "user://projects_list.json"
const SETTINGS_PATH = "user://app_settings.json"

# data format: { "ID": { "path": "", "name": "", "icon_override": "", "tags": [], "version": "" } }
var _projects_data: Dictionary = {}
var _app_locale: String = "en"

func _ready() -> void: 
	load_projects()
	load_settings()

func add_project(path: String, project_name: String = "Unnamed Project") -> void:
	var clean_path = path.replace("\\", "/").simplify_path()
	var project_id = str(clean_path.hash())
	
	if not _projects_data.has(project_id):
		_projects_data[project_id] = {
			"path": clean_path,
			"name": project_name,
			"icon_override": "",
			"tags": [],
			"version": ""
		}
		save_projects()

func update_project_name(project_id: String, new_name: String) -> void:
	if _projects_data.has(project_id) and _projects_data[project_id].get("name") != new_name:
		_projects_data[project_id]["name"] = new_name
		save_projects()

func update_project_version(project_id: String, new_version: String) -> void:
	if _projects_data.has(project_id) and _projects_data[project_id].get("version") != new_version:
		_projects_data[project_id]["version"] = new_version
		save_projects()

func update_project_path(old_id: String, new_file_path: String) -> void:
	if not _projects_data.has(old_id): return
	var clean_path = new_file_path.replace("\\", "/").simplify_path()
	var new_id = str(clean_path.hash())
	
	if old_id != new_id:
		var project_data = _projects_data[old_id].duplicate(true)
		project_data["path"] = clean_path
		_projects_data[new_id] = project_data
		_projects_data.erase(old_id)
	else: 
		_projects_data[old_id]["path"] = clean_path
		
	save_projects()

func remove_project(project_id: String) -> void:
	if _projects_data.erase(project_id):
		if EventBus.has_user_signal("project_removed"):
			EventBus.project_removed.emit()
		save_projects()

# --- project getters ---

func get_all_projects() -> Dictionary:
	return _projects_data

func get_project_by_id(project_id: String) -> Dictionary:
	return _projects_data.get(project_id, {})

func get_project_tags(project_id: String) -> Array:
	var project = get_project_by_id(project_id)
	return project.get("tags", [])

func get_project_name(project_id: String) -> String:
	return _projects_data.get(project_id, {}).get("name", "Unnamed Project")

func get_project_version(project_id: String) -> String:
	return _projects_data.get(project_id, {}).get("version", "Unknown")

# --- project setters ---

func set_project_icon(project_id: String, icon_path: String) -> void:
	if _projects_data.has(project_id):
		_projects_data[project_id]["icon_override"] = icon_path
		save_projects()

func add_tag(project_id: String, tag_name: String, color_hex: Color = Color("0e55c2")) -> void:
	if not _projects_data.has(project_id):
		printerr("Error: project with ID: ", project_id, " not found.")
		return
	var new_tag = {
		"name": tag_name, 
		"color": color_hex.to_html() 
	}
	_projects_data[project_id]["tags"].append(new_tag)
	save_projects()

func remove_tag_from_project(project_id: String, tag_name: String) -> void:
	if not _projects_data.has(project_id): return
	var tags = _projects_data[project_id]["tags"] as Array
	var index_to_remove = -1
	for i in range(tags.size()):
		if tags[i]["name"] == tag_name:
			index_to_remove = i
			break
	if index_to_remove != -1:
		tags.remove_at(index_to_remove)
		save_projects()

# --- app settings & locale ---

func set_app_locale(locale_code: String) -> void:
	if _app_locale != locale_code:
		_app_locale = locale_code
		TranslationServer.set_locale(_app_locale)
		save_settings()

func get_app_locale() -> String:
	return _app_locale

# --- file operations ---

func save_projects() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(_projects_data, "\t")
		file.store_string(json_string)
		file.close()
	else:
		printerr("Error: The file could not be opened for writing: ", SAVE_PATH)

func load_projects() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		var data = json.get_data()
		if data is Dictionary:
			_projects_data = data
	else:
		printerr("Error parsing of projects JSON: ", json.get_error_message())
	file.close()

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var settings_data = {
			"locale": _app_locale
		}
		file.store_string(JSON.stringify(settings_data, "\t"))
		file.close()
	else:
		printerr("Error: The file could not be opened for writing: ", SETTINGS_PATH)

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		_app_locale = OS.get_locale_language()
		TranslationServer.set_locale(_app_locale)
		return
		
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file: return
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		var data = json.get_data()
		if data is Dictionary and data.has("locale"):
			_app_locale = data["locale"]
			TranslationServer.set_locale(_app_locale)
	else:
		printerr("Error parsing settings JSON: ", json.get_error_message())
	file.close()
