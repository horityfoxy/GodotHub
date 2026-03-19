extends Node

const SAVE_PATH = "user://projects_list.json"
var projects_paths : Array = []

func _ready() -> void:
	load_projects()

func add_project(path: String) -> void:
	var clean_path = path.replace("\\", "/").simplify_path()
	var is_duplicate = false
	for existing_path in projects_paths:
		if OS.get_name() == "Windows":
			if existing_path.to_lower() == clean_path.to_lower():
				is_duplicate = true
				break
		else: # for Linux based
			if existing_path == clean_path:
				is_duplicate = true
				break
	
	if not is_duplicate:
		projects_paths.append(clean_path)
		save_projects()

func remove_project(path: String) -> void:
	if projects_paths.has(path):
		projects_paths.erase(path)
		save_projects()

func save_projects() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(projects_paths))
		file.close()

func load_projects() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data = json.get_data()
		if data is Array: projects_paths = data
	file.close()
