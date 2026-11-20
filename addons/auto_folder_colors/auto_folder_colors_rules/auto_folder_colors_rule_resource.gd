@tool
class_name AutoFolderColorsResource
extends Resource

## Ресурс правил цветовой схемы
##
## Для настроек под разные проекты

## Подставляется при вводе пустого значения в словарь правил
@export_enum(
	"red",
	"orange",
	"yellow",
	"green",
	"teal",
	"blue",
	"purple",
	"pink",
	"gray",
) var default_color: String = "gray"


#region folder_color_rules
## Разрешенные цвета, чтобы не допустить ошибку при вводе
const COLOR_OPTIONS := "red,orange,yellow,green,teal,blue,purple,pink,gray"

## Цветовая схема, используемая мной [br]
## Правила для папок [br]
## Более точное совпадение правил в приоритете [br]
## Ключи отсортированы по алфавиту с помощью онлайн сервисов [br]
@export var folder_color_rules: Dictionary[String, String] = {
	"_actions": "teal",
	"addons": "gray",
	"asset": "red",
	"assets": "red",
	"audio": "green",
	"autoloads": "gray",
	"config": "gray",
	"configuration": "orange",
	"doc": "purple",
	"docs": "purple",
	"examples": "pink",
	"font": "purple",
	"fonts": "purple",
	"game_ready": "teal",
	"localization": "green",
	"modules": "yellow",
	"music": "green",
	"renders": "red",
	"prefs": "teal",
	"resources": "blue",
	"shaders": "blue",
	"sounds": "green",
	"system": "orange",
	"_templates": "gray",
	}:
	get:
		return folder_color_rules
	set(value):
		## Фильтруем недопустимые значения
		var cleaned : Dictionary[String, String]= {}
		for key in value:
			## Чтобы пустые ключи в словарь не добавлялись
			if key == "":
				continue
			var col = str(value[key])
			if col in COLOR_OPTIONS.split(","):
				cleaned[key] = col
			else:
				cleaned[key] = default_color
		folder_color_rules = cleaned
		notify_property_list_changed()

#region TODO в будущем сделать совместимым с Fancy Folder Colors
## Цвета папок в Godot
## Не используется пока, но пригодится для быстрого понимания цвета
## Значения нельзя поменять
@export var named_colors : Dictionary[StringName, Color]= {
	"red":    Color(1.0, 0.271, 0.271),
	"orange": Color(1.0, 0.561, 0.271),
	"yellow": Color(1.0, 0.890, 0.271),
	"green":  Color(0.502, 1.0, 0.271),
	"teal":   Color(0.271, 1.0, 0.635),
	"blue":   Color(0.271, 0.843, 1.0),
	"purple": Color(0.502, 0.271, 1.0),
	"pink":   Color(1.0, 0.271, 0.588),
	"gray":   Color(0.616, 0.616, 0.616),
}:
	get:
		return named_colors
	set(value):
		pass
#endregion

func _validate_property(property: Dictionary) -> void:
	if property.name == &"folder_color_rules":
		property.hint_string =  "%d:;%d/%d:%s" % [
			TYPE_STRING,
			TYPE_STRING, PROPERTY_HINT_ENUM, COLOR_OPTIONS
		]
		property.hint = PROPERTY_HINT_DICTIONARY_TYPE
	if property.name == &"preferred_language":
		property.hint = PROPERTY_HINT_LOCALE_ID
#endregion


## Искать только целые слова или подстроку? [br]
## true  = папка "my_assets" сработает на "assets" [br]
## false = только точное совпадение имени папки
@export var match_substring: bool = true

## Применять цвета автоматически при включении плагина?
@export var auto_apply_on_enable: bool = false

## Для перевода сообщений, предпочитаемый язык
@export var preferred_language: String = ""
