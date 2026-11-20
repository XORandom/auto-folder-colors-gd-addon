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
	"addons": "gray",
	"asset": "red",
	"assets": "gray",
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
	"prefs": "teal",
	"resources": "blue",
	"shaders": "blue",
	"sounds": "green",
	"system": "orange",
	"test": "yellow"
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


func _validate_property(property: Dictionary) -> void:
	if property.name == &"folder_color_rules":
		property.hint_string = "String;4/%d:%s" % [PROPERTY_HINT_ENUM, COLOR_OPTIONS]
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
