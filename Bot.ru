import os
import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import InlineKeyboardButton, InlineKeyboardMarkup
from aiohttp import web

TOKEN = os.getenv("BOT_TOKEN", "")
AUTHOR_NICK = "@OlgaVVeles"

bot = Bot(token=TOKEN)
dp = Dispatcher()

def litres_link(item_id):
    return f"https://www.litres.ru/?utm_source=advcake&utm_medium=cpa&utm_campaign=affiliate&utm_content=74f5ddf0&advcake_params=&utm_term=&keyword=https%3A%2F%2Fwww.litres.ru%2F{item_id}%2F&erid=2VfnxyNkZrY&advcake_method=1&m=1"

BOOKS = {
    "slavic": {
        "title": "🗡 Славянское фэнтези",
        "items": [
            ("Велесовские хроники",
             "Наш современник попадает в Древнюю Русь X века. Языческие боги — не легенды, а реальная сила. Он — последний носитель Знака Велеса.",
             "159", "73529413", None, None),
            ("Велесовские хроники: Велес",
             "Андрей учится у Марены древним заговорам, а Черномор собирает силы в Нави.",
             "119", "73528918", "299", "73529038"),
            ("Велесовские хроники: Печать Нави",
             "Врата трещат, нечисть просыпается. Андрей ищет древние печати, чтобы остановить тьму.",
             "109", "73528958", "199", "73898489"),
            ("Велесовские хроники: Сварог",
             "Забытый бог огня пробуждается. Андрей ищет древний молот, чтобы запечатать его.",
             "109", "73525598", "299", "73533458"),
            ("Лада. Путь сквозь миры",
             "Юная Лада сажает саженец Древа равновесия — и осознаёт, что её миссия куда масштабнее.",
             "199", "73832107", "259", "73898899"),
            ("Волчья звезда",
             "Ольга Велесова и амулет Волчья звезда. Разбойники, жрицы тёмного культа и лес, который помнит всё.",
             "199", "73807689", "199", "73898739"),
            ("Русские Саги: Войны",
             "Эпическое фэнтези о борьбе за власть. Стихийная магия, руны, интриги и древнее зло.",
             "199", "73528823", None, None),
            ("Тени древних лесов (Берёзовый шёпот)",
             "В глухих лесах Воронежской земли пробуждается древнее зло. Русалки, домовые, лешие — всё по-настоящему.",
             "159", "73888576", "199", "73935649"),
            ("Хроники славянской нечисти",
             "Домовые, овинники, банники, кикиморы, водяные, оборотни, баба-Яга — полный бестиарий славянской мифологии.",
             "229", "73993091", "199", "73998914"),
            ("Тени забытых богов",
             "Забытые боги оставили осколки силы. Обычный антиквар — последний, кто может остановить возрождение бога теней.",
             "99", "73862419", "249", "73879231"),
        ]
    },
    "horror": {
        "title": "💀 Ужасы и мистика",
        "items": [
            ("Не открывай эту дверь",
             "Зло просачивается сквозь щели: в скрип моста, в дверь, которой вчера не было. Панельные окраины, глухие трассы — и тишина, в которой кто-то проводит ногтем по стене.",
             "249", "74132763", "309", "74145713"),
            ("Проклятые деревни России",
             "Сборник страшных историй о проклятых местах. Мир полон тайн, а память — самая сильная магия.",
             "229", "73541563", None, None),
            ("Глухомань",
             "Герой пытается вырваться из цикла проклятия, но связь с Глухоманью не разорвана. Лес помнит, лес зовёт.",
             "199", "73551498", None, None),
            ("Проклятые страницы",
             "Дом, выбирающий жертв в тумане. Аудиокассеты, стирающие память. Нейроимплант, заменяющий разум. После этих историй вы перестанете доверять темноте.",
             "199", "73574023", "199", "73585683"),
            ("Тени Рамони",
             "Туман над рекой Воронеж, посёлок Рамонь и дворец Ольденбургских. То, что пробудилось за кирпичными стенами, не должно было проснуться.",
             "199", "73551148", "229", "73561143"),
            ("Город, которого нет на карте",
             "Есть места, которых нет на картах. Дома, что помнят то, что забыли люди. Ключи, открывающие двери туда, где реальность теряет форму.",
             "149", "73866538", "199", "73883461"),
        ]
    },
    "detective": {
        "title": "🔍 Детективы",
        "items": [
            ("Дело о пропавшем домовом",
             "Городок Лукоморск, где магия сосуществует с людьми. Обычный парень — посредник между миром людей и нечистью. Кот говорит, домовой сбежал, маршрутка №13 исчезла в тумане.",
             "199", "73530023", "199", "73743139"),
            ("Тайна пропавшей книги, или Призрак Достоевского",
             "Лизавета Книжкина расследует пропажу редких изданий Достоевского. Кто-то подменяет оригиналы подделками — культурная диверсия!",
             "149", "73800671", "239", "73898988"),
            ("Тайны бабушкиного буфета, или Убийство на компоте",
             "Евгения Мартынова и кот-детектив Барсик расследуют отравление вишнёвым компотом. Уютный детектив с медальонами и граммофонами.",
             "149", "73577408", "199", "73601661"),
            ("Тени на стекле",
             "Марк и Анна разгадывают шифры веков. От Серебряной книги до Звёздного камня — каждый артефакт несёт предупреждение.",
             "149", "73852769", "199", "73863721"),
        ]
    },
    "romance": {
        "title": "💕 Любовные романы",
        "items": [
            ("Ветер над заливом",
             "Короткий любовный роман о ветре, перемене и чувствах, которые настигают неожиданно.",
             "149", "73797937", None, None),
            ("Любовь между страниц",
             "Элиана находит письмо столетней давности. Встреча с загадочным аристократом Ричардом — второй шанс на любовь.",
             "149", "73795632", None, None),
            ("Мелодия наших сердец",
             "Музыка — язык, который понимает каждый. Любовь — сила, которая ведёт вперёд.",
             "159", "73795691", None, None),
            ("Свет Рамони",
             "История о доброте принцессы Эжени, которая превратила Рамонь в место, где мечты становятся реальностью.",
             "199", "73551103", "199", "74063514"),
            ("Эскиз счастья",
             "Случайная встреча перерисовывает жизненные линии. Роман о поиске себя и о том, что счастье складывается из деталей.",
             "149", "73797919", None, None),
            ("Синие сумерки перемен",
             "Переезд, новая школа, чужой город. Лиза думала, самое трудное — оставить прошлое. Но главное испытание ждёт впереди.",
             "149", "73922299", None, None),
        ]
    },
    "history": {
        "title": "📜 Историческое и драма",
        "items": [
            ("Хроники Лианы Ольденбургской: клятвы",
             "Принцесса Лиана видит трещины в ткани реальности. Древние клятвы распадаются, и мир трещит по швам.",
             "119", "73807642", "229", "73898741"),
            ("Хроники Лианы Ольденбургской: магия и резонатор",
             "Лиана, Эрик и Рейн отправляются к Источнику магии. Печаль, сдерживающая древнее зло, слабеет.",
             "119", "73531683", None, None),
            ("Сказки старого дуба, или Память о доброй принцессе Рамонской",
             "Принцесса Эжени превратила Рамонь в место, где мечты становятся реальностью. Волшебная история о доброте.",
             "199", "73801231", None, None),
            ("Мы вернемся домой",
             "История о семье, любви и вере в самые тёмные времена. О невидимой нити, которая связывает людей, несмотря на километры и грохот снарядов.",
             "199", "74091459", "199", "74095704"),
            ("Перекрёстки судьбы",
             "Юные музыканты Катя и Артём выбирают свободу творчества вместо славы. История о выборе и смелости.",
             "149", "73832501", None, None),
            ("Ветер перемен",
             "История трёх братьев. О семье, которая не сломалась. О городе, который ожил. О надежде, которую можно построить своими руками.",
             "149", "73832292", None, None),
        ]
    },
    "kids": {
        "title": "🧒 Сказки для детей",
        "items": [
            ("Волшебные сказки о Кирилле и Даше: путешествие в мир чудес",
             "Книга о многодетной семье и магии повседневной жизни. О семейных ценностях, дружбе и радости маленьких открытий.",
             "149", "73504113", "199", "74277718"),
            ("Волшебные сказки о Кирилле и Даше: полный сборник",
             "Все истории о Кирилле и Даше в одной книге. Магия есть в каждом дне, если смотреть с открытым сердцем.",
             "149", "73503723", None, None),
            ("Волшебные приключения Кирилла и Даши",
             "Новые приключения! Дружба, смелость и любовь всегда побеждают в бесконечном мире фантазии.",
             "149", "73544733", None, None),
        ]
    },
    "free": {
        "title": "🎁 Бесплатно",
        "items": [
            ("Слово пацана (фанфик)",
             "Более фантастическое завершение истории. Марат и Айгуль решают уйти от уличных разборок. Фанфик по сериалу «Слово пацана».",
             "0", "73513458", None, None),
        ]
    }
}

def main_menu():
    kb = [
        [InlineKeyboardButton(text="🗡 Славянское фэнтези", callback_data="cat_slavic")],
        [InlineKeyboardButton(text="💀 Ужасы и мистика", callback_data="cat_horror")],
        [InlineKeyboardButton(text="🔍 Детективы", callback_data="cat_detective")],
        [InlineKeyboardButton(text="💕 Любовные романы", callback_data="cat_romance")],
        [InlineKeyboardButton(text="📜 Историческое и драма", callback_data="cat_history")],
        [InlineKeyboardButton(text="🧒 Сказки для детей", callback_data="cat_kids")],
        [InlineKeyboardButton(text="🎁 Бесплатно", callback_data="cat_free")],
        [InlineKeyboardButton(text="🎧 Все аудиокниги на ЛитРес", url=litres_link("author/olga-v-veles/?art_types=audio"))],
        [InlineKeyboardButton(text="📚 Все книги на ЛитРес", url=litres_link("author/olga-v-veles/"))],
        [InlineKeyboardButton(text="❓ FAQ и помощь", callback_data="help")],
        [InlineKeyboardButton(text="📩 Написать автору", url=f"https://t.me/{AUTHOR_NICK}")],
    ]
    return InlineKeyboardMarkup(inline_keyboard=kb)

def category_menu(cat_key):
    cat = BOOKS[cat_key]
    kb = []
    for i, (title, _, _, _, _, _) in enumerate(cat["items"]):
        kb.append([InlineKeyboardButton(text=f"📖 {title}", callback_data=f"book_{cat_key}_{i}")])
    kb.append([InlineKeyboardButton(text="🔙 Назад в меню", callback_data="menu")])
    return InlineKeyboardMarkup(inline_keyboard=kb)

def book_card(cat_key, idx):
    cat = BOOKS[cat_key]
    title, desc, t_price, t_id, a_price, a_id = cat["items"][idx]

    if t_price == "0":
        price_line = "🎁 Бесплатно"
    else:
        price_line = f"💰 Текст: {t_price} ₽"

    if a_price is not None:
        price_line += f"  |  🎧 Аудио: {a_price} ₽"

    text = f"📖 {title}\n\n{desc}\n\n{price_line}\n"

    buttons = []
    if t_price == "0":
        buttons.append([InlineKeyboardButton(text="📥 Читать бесплатно", url=f"https://www.litres.ru/{t_id}/")])
    else:
        buttons.append([InlineKeyboardButton(text="📖 Читать (текст)", url=litres_link(t_id))])

    if a_id is not None:
        buttons.append([InlineKeyboardButton(text="🎧 Слушать (аудио)", url=litres_link(a_id))])

    buttons.append([InlineKeyboardButton(text="💬 Поделиться", switch_inline_query=f"Присмотри книгу: {title}")])
    buttons.append([InlineKeyboardButton(text="🔙 Назад", callback_data=f"cat_{cat_key}")])

    return text, InlineKeyboardMarkup(inline_keyboard=buttons)

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    await message.answer(
        "Привет! Я книжный бот Ольги В. Велес (Елютиной). 📚\n\n"
        "Здесь все мои книги — славянское фэнтези, ужасы, детективы, романы и сказки.\n"
        "Многие доступны и в аудиоформате — ищи кнопку «Слушать».\n\n"
        "Что читаем? Выбирай жанр 👇",
        reply_markup=main_menu()
    )

@dp.callback_query(lambda c: c.data == "menu")
async def show_menu(callback: types.CallbackQuery):
    await callback.message.edit_text("Что читаем? Выбирай жанр 👇", reply_markup=main_menu())
    await callback.answer()

@dp.callback_query(lambda c: c.data.startswith("cat_"))
async def show_category(callback: types.CallbackQuery):
    cat_key = callback.data[4:]
    if cat_key not in BOOKS:
        await callback.answer()
        return
    cat = BOOKS[cat_key]
    await callback.message.edit_text(f"{cat['title']}\n\nВыбери книгу 👇", reply_markup=category_menu(cat_key))
    await callback.answer()

@dp.callback_query(lambda c: c.data.startswith("book_"))
async def show_book(callback: types.CallbackQuery):
    parts = callback.data.split("_")
    cat_key = parts[1]
    idx = int(parts[2])
    if cat_key not in BOOKS or idx >= len(BOOKS[cat_key]["items"]):
        await callback.answer()
        return
    text, kb = book_card(cat_key, idx)
    await callback.message.edit_text(text, reply_markup=kb, disable_web_page_preview=True)
    await callback.answer()

@dp.callback_query(lambda c: c.data == "help")
async def show_help(callback: types.CallbackQuery):
    text = (
        "📚 FAQ:\n\n"
        "— Все книги продаются на ЛитРес: после покупки получаешь fb2, epub, pdf или аудио (mp3, m4b).\n"
        "— Многие книги доступны по подписке ЛитРес.\n"
        "— Если есть кнопка «Слушать» — у книги есть аудиоверсия.\n"
        "— Возврат и поддержка — через службу поддержки ЛитРес.\n"
        "— Возрастные ограничения указаны на странице каждой книги.\n\n"
        f"Вопросы? Напиши мне: @{AUTHOR_NICK}"
    )
    kb = InlineKeyboardMarkup(inline_keyboard=[[InlineKeyboardButton(text="🔙 Назад", callback_data="menu")]])
    await callback.message.edit_text(text, reply_markup=kb)
    await callback.answer()

# --- Webhook для Render ---

WEBAPP_HOST = "0.0.0.0"
WEBAPP_PORT = int(os.getenv("PORT", 8080))
WEBHOOK_PATH = "/webhook"

async def handle_update(request: web.Request):
    data = await request.json()
    update = types.Update(**data)
    await dp.feed_update(bot, update)
    return web.Response(status=200)

async def on_startup(app):
    render_host = os.getenv("RENDER_EXTERNAL_HOSTNAME")
    if render_host:
        webhook_url = f"https://{render_host}{WEBHOOK_PATH}"
        await bot.set_webhook(webhook_url)
        print(f"Webhook установлен: {webhook_url}")
    else:
        print("Внимание: RENDER_EXTERNAL_HOSTNAME не задан!")

async def on_cleanup(app):
    await bot.delete_webhook()

async def main():
    app = web.Application()
    app.router.add_post(WEBHOOK_PATH, handle_update)
    app.on_startup.append(on_startup)
    app.on_cleanup.append(on_cleanup)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, WEBAPP_HOST, WEBAPP_PORT)
    await site.start()
    print(f"Сервер запущен на {WEBAPP_HOST}:{WEBAPP_PORT}")
    while True:
        await asyncio.sleep(3600)

if __name__ == "__main__":
    asyncio.run(main())
