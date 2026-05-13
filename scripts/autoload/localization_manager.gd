extends Node

enum Language { RUSSIAN, ENGLISH }

var current_language: Language = Language.RUSSIAN

# Сигнал для обновления всех текстов в игре при смене языка
signal language_changed(new_language: Language)

# ========================================
# СИСТЕМНЫЕ НАДПИСИ (интерфейс, кнопки)
# ========================================
var system_texts = {
	"game_title": {
		Language.RUSSIAN: "Pelmeny`s Secret",
		Language.ENGLISH: "Pelmeny`s Secret"
	},
	"new_game": {
		Language.RUSSIAN: "Новая игра",
		Language.ENGLISH: "New Game"
	},
	"continue": {
		Language.RUSSIAN: "Продолжить",
		Language.ENGLISH: "Continue"
	},
	"exit": {
		Language.RUSSIAN: "Выход",
		Language.ENGLISH: "Exit"
	},
	"pause": {
		Language.RUSSIAN: "ПАУЗА",
		Language.ENGLISH: "PAUSE"
	},
	"save": {
		Language.RUSSIAN: "Сохранить",
		Language.ENGLISH: "Save"
	},
	"main_menu": {
		Language.RUSSIAN: "Главное меню",
		Language.ENGLISH: "Main Menu"
	},
	"loading": {
		Language.RUSSIAN: "Загрузка...",
		Language.ENGLISH: "Loading..."
	},
	"press_e_to_teleport": {
		Language.RUSSIAN: "Нажмите E для телепортации",
		Language.ENGLISH: "Press E to teleport"
	},
	"splash_subtitle": {
		Language.RUSSIAN: "Секрет пельменей",
		Language.ENGLISH: "The Secret of Dumplings"
	},
	# Отладочная панель
	"debug_controls": {
		Language.RUSSIAN: "Стрелки/WASD - движение\nE - телепорт\nC - коллизии\nH - скрыть подсказку\nESC - меню",
		Language.ENGLISH: "Arrows/WASD - move\nE - teleport\nC - collisions\nH - hide info\nESC - menu"
	},
	"debug_fps": {
		Language.RUSSIAN: "FPS",
		Language.ENGLISH: "FPS"
	},
	# Сообщения
	"game_saved": {
		Language.RUSSIAN: "Игра сохранена!",
		Language.ENGLISH: "Game saved!"
	},
	"map_not_found": {
		Language.RUSSIAN: "Файл карты не найден",
		Language.ENGLISH: "Map file not found"
	},
	"error_loading_map": {
		Language.RUSSIAN: "Ошибка загрузки карты",
		Language.ENGLISH: "Error loading map"
	}
}

# ========================================
# ДИАЛОГОВЫЕ РЕПЛИКИ (твой ReplicsManager)
# ========================================
var replicas_russian = [
	"*ням-ням-ням*",
	"Всё это не то!",
	"На вкус как пенопласт!",
	"Да даже он вкуснее!!!",
	"А вот раньше было…",
	"25 лет назад...",
	"*ням-ням-ням*",
	"Бабушка, твои пельмешки самые-самые вкусные!!!",
	"А почему так?",
	"Хех",
	"А всё дело, внучок, в секретном ингредиенте",
	"А что это за ингридиент такой?",
	"Потом сам как-нибудь узнаешь...",
	"Надо навестить бабушку.",
	"Решено! Отправляюсь во Владивосток!",
	"Секрет пельменей",
	"Так... Москва-Владивосток...",
	"Ох, дорого блин, ну да ладно, что делать..",
	"Отправление через час...",
	"Неделю спустя..",
	"Такс... Осталось найти её дом...",
	"Спасибо тебе, внучок!",
	"Бабушка, а почему они такие вкусные?",
	"Этот ингридиент - моя любовь",
	"Как это мило, бабушка ^^",
	"Zzz..",
	"Интересный какой, спит на работе",
	"Ой, смотри-ка, Марин, солнечный какой! Ты к кому, милок?",
	"Да это ж, кажется, сынок Люды из пятого! Вылитый!",
	"Я... я просто мимо.",
	"А, ну ладно! У нас тут сирень как зацвела – душища!",
	"И Барсик наш, лежебока, на третьей лавочке развалился. Не наступи на него!",
	"Хочешь, загадку загадаю? Что в землю сажаем, всё лето поливаем, а осенью внучки уплетают?",
	"Картошку?",
	"Деньги?",
	"Любовь в банках! Варенье да соленья!",
	"Умничка! Чувствуется, из хорошей семьи!",
	"На, пирожок с яблоком, домашний. Тёплый ещё! Иди, не задерживай!",
	"Ой-ой-ой! Куда это мы собрались?",
	"А пропуск формы 7-Г покажете? Или может, удостоверение счастливого человека?",
	"Я... мне просто нужно выйти.",
	"«Просто выйти»! Ха-ха! Все так говорят!",
	"Ладно, шучу. Вижу вы человек приятный. Давайте сыграем: угадаете – пропущу!",
	"Что идёт вверх и вниз, но с места не сдвинется ни на сантиметр?",
	"Лифт",
	"Температура",
	"Лестница",
	"Молодец! Раз такие дела – вот вам временный пропуск. Только никому не говорите!",
	"Извиняй, видимо сегодня не твой день"
]

var replicas_english = [
	"*yum-yum-yum*",
	"This is all wrong!",
	"Tastes like styrofoam!",
	"Even that tastes better!!!",
	"But it was better back in the day...",
	"25 years ago...",
	"*yum-yum-yum*",
	"Grandma, your dumplings are the absolute best!!!",
	"Why is that?",
	"Heh",
	"Well, grandson, it's all about the secret ingredient",
	"What kind of ingredient is that?",
	"You'll find out some other time...",
	"I need to visit Grandma.",
	"It's decided! I'm going to Vladivostok!",
	"Pelmeny`s secret",
	"So... Moscow to Vladivostok...",
	"Oh, that's expensive, damn, oh well, what can you do..",
	"Departure in an hour...",
	"A week later..",
	"So... Now I have to find her house...",
	"Thank you, dear grandson!",
	"Grandma, why are they so tasty?",
	"This ingredient is my love.",
	"That's so sweet, grandma ^^",
	"Zzz...",
	"My, my, sleeping on the job, how interesting",
	"Oh, look, Marina, what a sunny young man! Who are you here for, dear?",
	"Wait, isn't that Lyuda's boy from the fifth floor? The spitting image!",
	"I... I was just passing by.",
	"Ah, alright then! Our lilac is in full bloom – such a fragrance!",
	"And our lazybones, Barsik the cat, is sprawling on the third bench. Don't step on him!",
	"Want me to tell you a riddle? What do we plant in the ground, water all summer, and our granddaughters devour in the fall?",
	"Potatoes?",
	"Money?",
	"Love in jars! Jam and pickles!",
	"Clever girl! I can tell you're from a good family!",
	"Here, have an apple pie, homemade. Still warm! Go on now, don't linger!",
	"Oh, dear, dear! And where might we be off to?",
	"May I see your Form 7-G pass? Or perhaps your happy-person identification?",
	"I... I just need to get out.",
	"'Just get out'! Ha-ha! They all say that!",
	"Alright, I'm joking. I can see you're a pleasant person. Let's play a game: guess right – I'll let you pass!",
	"What goes up and down but doesn't move an inch from its spot?",
	"An elevator",
	"Temperature",
	"Stairs",
	"Well done! Since that's the case – here's a temporary pass for you. Just don't tell anyone!",
	"Sorry, looks like it's just not your day"
]


# ========================================
# МЕТОДЫ
# ========================================

func get_text(key: String) -> String:
	"""Получить системный текст по ключу"""
	if system_texts.has(key):
		return system_texts[key].get(current_language, key)
	return key


func get_replica(index: int) -> String:
	"""Получить диалоговую реплику по индексу"""
	if current_language == Language.RUSSIAN:
		if index >= 0 and index < replicas_russian.size():
			return replicas_russian[index]
	else:
		if index >= 0 and index < replicas_english.size():
			return replicas_english[index]
	return ""


func set_language(lang: Language) -> void:
	"""Установить язык и оповестить все элементы интерфейса"""
	if current_language != lang:
		current_language = lang
		language_changed.emit(lang)


func toggle_language() -> void:
	"""Переключить язык"""
	if current_language == Language.RUSSIAN:
		set_language(Language.ENGLISH)
	else:
		set_language(Language.RUSSIAN)


func get_current_language_string() -> String:
	"""Получить строковое обозначение текущего языка"""
	if current_language == Language.RUSSIAN:
		return "Русский"
	return "English"
