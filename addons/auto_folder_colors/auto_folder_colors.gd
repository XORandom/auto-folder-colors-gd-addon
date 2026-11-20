@tool
extends EditorPlugin

## AutoFolderColors
##
## by XORandom, 2026
# TODO нужна панель настроек и все правила, чтобы не лезть в код
# Сделать совместимым с Fancy Folder Colors https://godotengine.org/asset-library/asset/3859
# Проверять в реальном времени изменения в файловой системе
# Создание и переименовнаие папки TODO




## auto_folder_colors_rules_resource.folder_color_rules
## auto_folder_colors_rules_resource.match_substring
## auto_folder_colors_rules_resource.auto_apply_on_enable
## auto_folder_colors_rules_resource.preferred_language
var auto_folder_colors_rules_resource = preload("uid://cpehbfjjpof5r")

var current_colors_rules: Dictionary[String, String] = {}
var current_match_substring: bool = false
var current_auto_apply_on_enable: bool = false

## Для перевода сообщений
var preferred_language: String = ""

## Есть ли изменение при сканировании
var changed := false

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	current_colors_rules = auto_folder_colors_rules_resource.folder_color_rules
	current_match_substring = auto_folder_colors_rules_resource.match_substring
	current_auto_apply_on_enable = auto_folder_colors_rules_resource.auto_apply_on_enable
	preferred_language = auto_folder_colors_rules_resource.preferred_language
	#print("_enter_tree", current_colors_rules, current_match_substring, current_auto_apply_on_enable, preferred_language)

	add_tool_menu_item("Apply Auto Folder Colors", _on_apply_colors)
	if current_auto_apply_on_enable:
		if preferred_language == "ru":
			print("Включено автоматическое применение цветов при включении плагина")
		else:
			print("The automatic application of colors is enabled when the plugin is turned on.")
		_apply_colors()
	# TODO подумать, как обновлять корректно, этот вариант слишком нагружает систему
	#if not EditorInterface.get_resource_filesystem().filesystem_changed.is_connected(_apply_colors):
		#EditorInterface.get_resource_filesystem().filesystem_changed.connect(_apply_colors)

	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	remove_tool_menu_item("Apply Auto Folder Colors")
	# TODO подумать, как обновлять корректно, этот вариант слишком нагружает систему
	#if EditorInterface.get_resource_filesystem().filesystem_changed.is_connected(_apply_colors):
		#EditorInterface.get_resource_filesystem().filesystem_changed.disconnect(_apply_colors)

	# Clean-up of the plugin goes here.
	pass


## Срабатывает при нажатии кнопки
func _on_apply_colors() -> void:
	_apply_colors()
	if preferred_language == "ru":
		print_rich("[b][Auto Folder Colors][/b] Цвета применены к папкам и сохранены в project.godot.")
	else:
		print_rich("[b][Auto Folder Colors][/b] Colors applied and saved in project.godot")


## Функция для сохранения цветов в project.godot
func _apply_colors() -> void:
	current_colors_rules = auto_folder_colors_rules_resource.folder_color_rules
	current_match_substring = auto_folder_colors_rules_resource.match_substring
	current_auto_apply_on_enable = auto_folder_colors_rules_resource.auto_apply_on_enable
	preferred_language = auto_folder_colors_rules_resource.preferred_language
	#print("_apply_colors", current_colors_rules, current_match_substring, current_auto_apply_on_enable, preferred_language)
	if preferred_language == "":
		preferred_language = OS.get_locale_language()
	var folder_colors: Dictionary = ProjectSettings.get_setting(
		"file_customization/folder_colors", {}
	).duplicate()

	var root := "res://"
	_scan_directory(root, folder_colors, changed)

#region changed
	#if changed:
	ProjectSettings.set_setting("file_customization/folder_colors", folder_colors)
	ProjectSettings.save()
	var fs_dock = get_editor_interface().get_file_system_dock()
	if fs_dock and fs_dock.has_method("_update_tree"):
		fs_dock._update_tree()

	## Пересканируем, чтобы эффект был сразу
	EditorInterface.get_resource_filesystem().scan()
#endregion


func _scan_directory(path: String, folder_colors: Dictionary, changed: bool) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var full_path: String = path.path_join(file_name)
			var store_path: String = full_path
			## Пути должны заканчиваться /
			if not store_path.ends_with("/"):
				store_path += "/"

			var color_name: String = _get_color_for_folder2(file_name)
			if color_name != "":
				if folder_colors.get(store_path) != color_name:
					folder_colors[store_path] = color_name
					changed = true
					if preferred_language == "ru":
						print_rich("Папка {0} покрашена в цвет [color={1}]{1}[/color]".format([store_path, color_name]))
					else:
						print_rich("Colored: {0} → [color={1}]{1}[/color]".format([store_path, color_name]))
			## Рекурсивный вызов этого же метода
			_scan_directory(full_path, folder_colors, changed)

		file_name = dir.get_next()
	dir.list_dir_end()


## TODO сделать как у Templater,
## когда срабатывает только самое точное правило, а не первое
## Но для текущих целей подойдёт TODO
func _get_color_for_folder(folder_name: String) -> String:
	var lower_name: String = folder_name.to_lower()
	for keyword: String in current_colors_rules:
		var key: String = keyword.to_lower()
		if current_match_substring:
			if lower_name.contains(key):
				return current_colors_rules[keyword]
		else:
			if lower_name == key:
				return current_colors_rules[keyword]
	return ""


## Чтобы применялось только самое точное совпадение
func _get_color_for_folder2(folder_name: String) -> String:
	var lower_name: String= folder_name.to_lower()
	var best_match: String= ""
	var best_length: int = -1

	for keyword: String in current_colors_rules:
		var key: String = keyword.to_lower()
		var is_match: bool = false
		if current_match_substring:
			is_match = lower_name.contains(key)
		else:
			is_match = lower_name == key

		if is_match and key.length() > best_length:
			best_match = keyword
			best_length = key.length()
	if best_match != "":
		return current_colors_rules[best_match]
	return ""
