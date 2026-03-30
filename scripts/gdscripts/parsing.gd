extends VBoxContainer

signal new_version_found
signal network_connection_error

@export var check_godot_4: CheckBox
@export var check_godot_3: CheckBox
@export var panel_scene: PackedScene = preload("res://nodes/UI/engine_version_parsing_panel.tscn")
@onready var http_request: HTTPRequest = $HTTPRequest

var windows_releases: Array = []
var linux_releases: Array = []

func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)
	if EventBus.has_signal("version_update"):
		EventBus.version_update.connect(update_ui)

func ping_test() -> bool:
	var ping_req = HTTPRequest.new()
	add_child(ping_req)
	ping_req.timeout = 3.0
	var error = ping_req.request("https://api.github.com", ["User-Agent: GodotHub-Client"], HTTPClient.METHOD_HEAD)
	if error != OK:
		ping_req.queue_free()
		return false
	var result = await ping_req.request_completed
	ping_req.queue_free()
	return result[0] == HTTPRequest.RESULT_SUCCESS and result[1] == 200

func fetch_godot_releases() -> void:
	var _is_connected = await ping_test()
	if not _is_connected:
		network_connection_error.emit()
		return
	var url = "https://api.github.com/repos/godotengine/godot/releases"
	var headers = ["User-Agent: GodotHub-Client"]
	var error = http_request.request(url, headers)
	if error != OK: push_error("Error request: %d" % error)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: return
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK: return
	var releases = json.get_data()
	windows_releases.clear()
	linux_releases.clear()
	for release in releases: _process_release_assets(release)
	windows_releases.sort_custom(_compare_versions)
	linux_releases.sort_custom(_compare_versions)
	
	update_ui()

func update_ui() -> void:
	var filter_4 = check_godot_4.button_pressed
	var filter_3 = check_godot_3.button_pressed
	var show_all = (filter_4 == filter_3)
	var active_downloads: Array[String] = []
	for child in get_children():
		if child is Panel:
			if child.get("is_downloading") == true:
				var pure_version = child._version_text_label.replace("Godot engine ", "").strip_edges()
				active_downloads.append(pure_version)
				var is_v4 = pure_version.begins_with("4")
				var is_v3 = pure_version.begins_with("3")
				if show_all or (filter_4 and is_v4) or (filter_3 and is_v3): child.show()
				else: child.hide()
				continue
			child.queue_free()
	var filtered_list: Array = []
	var source_list = windows_releases if OS.get_name() == "Windows" else linux_releases
	for item in source_list:
		var version_str = item["version"]
		var is_v4 = version_str.begins_with("v4") or version_str.begins_with("4")
		var is_v3 = version_str.begins_with("v3") or version_str.begins_with("3")
		if show_all: filtered_list.append(item)
		elif filter_4 and is_v4: filtered_list.append(item)
		elif filter_3 and is_v3: filtered_list.append(item)
	_display_releases(filtered_list, active_downloads)

func _process_release_assets(release_data: Dictionary) -> void:
	var assets = release_data.get("assets", [])
	var version_tag = release_data.get("tag_name", "Unknown")
	for asset in assets:
		var file_name: String = asset.get("name", "")
		var url: String = asset.get("browser_download_url", "")
		if file_name.match("Godot_v*-stable_win64.exe.zip"):
			windows_releases.append({"version": version_tag, "url": url})
		elif (file_name.match("Godot_v*-stable_linux.x86_64.zip") or \
			  file_name.match("Godot_v*-stable_x11.64.zip")):
			if not file_name.ends_with(".tar.xz"):
				linux_releases.append({"version": version_tag, "url": url})

func _display_releases(data_list: Array, active_downloads: Array = []) -> void:
	for item in data_list:
		var pure_version = item["version"].replace("v", "").replace("-stable", "").replace("stable", "").strip_edges()
		if pure_version in active_downloads: continue
		var instance = panel_scene.instantiate()
		add_child(instance)
		var target_index = max(0, get_child_count() - 2)
		move_child(instance, target_index)
		if instance.has_method("set_version_text"): instance.set_version_text("Godot engine " + pure_version)
		if instance.has_method("set_link"): instance.set_link(item["url"])
		new_version_found.emit()

func _compare_versions(a: Dictionary, b: Dictionary) -> bool:
	var v1 = _version_to_int_array(a["version"])
	var v2 = _version_to_int_array(b["version"])
	
	for i in range(min(v1.size(), v2.size())):
		if v1[i] > v2[i]: return true
		if v1[i] < v2[i]: return false
	return v1.size() > v2.size()

func make_file_executable(file_path: String) -> void:
	if OS.get_name() == "Linux" or OS.get_name() == "macOS":
		var output = []
		OS.execute("chmod", ["+x", file_path], output)

func _version_to_int_array(version_string: String) -> Array:
	var clean = version_string.get_slice("-", 0).replace("v", "")
	var parts = clean.split(".")
	var ints = []
	for p in parts:
		if p.is_valid_int(): ints.append(p.to_int())
	return ints
