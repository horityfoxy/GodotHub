extends Node

const SAVE_PATH = "user://projects_list.json"

# data format: { "ID": { "path": "", "icon_override": "", "tags": [] } }
var _projects_data: Dictionary = {}

func _ready() -> void: load_projects()

func add_project(path: String) -> void:
	var clean_path = path.replace("\\", "/").simplify_path()
	var project_id = str(clean_path.hash())
	
	if not _projects_data.has(project_id):
		_projects_data[project_id] = {
			"path": clean_path,
			"icon_override": "",
			"tags": []
		}
		save_projects()

func remove_project(project_id: String) -> void:
	if _projects_data.erase(project_id):
		save_projects()

# --- getters ---

## Returns a dictionary with all projects
func get_all_projects() -> Dictionary:
	return _projects_data

## Returns the data of a specific project by ID
func get_project_by_id(project_id: String) -> Dictionary:
	return _projects_data.get(project_id, {})

## Returns the tags of a specific project
func get_project_tags(project_id: String) -> Array:
	var project = get_project_by_id(project_id)
	return project.get("tags", [])

# --- setters ---

func set_project_icon(project_id: String, icon_path: String) -> void:
	if _projects_data.has(project_id):
		_projects_data[project_id]["icon_override"] = icon_path
		save_projects()

## Add tag
func add_tag(project_id: String, tag_name: String, color_hex: Color = Color("0e55c2")) -> void:
	if not _projects_data.has(project_id):
		printerr("Error: project with ID: ", project_id, " not found.")
		return
	var new_tag = {
		"name": tag_name, 
		"color": color_hex
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
		printerr("Error parcing of JSON: ", json.get_error_message())
	file.close()
