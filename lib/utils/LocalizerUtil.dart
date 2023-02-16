import 'package:shared_preferences/shared_preferences.dart';

class Localizer {
  static var _localize = 'ru';
  static var _words = {
    "login_as": {
      "en": "Login as...",
      "ru": "Вход как...",
      "kz": "Retınde kıru..."
    },
    "worker": {"en": "Worker", "ru": "Работник", "kz": "Jūmysşy"},
    "admin": {"en": "Admin", "ru": "Админ", "kz": "Admin"},
    "fill": {"en": "Fill", "ru": "Заполнить", "kz": "Toltyru"},
    "phone_admin": {
      "en": "Phone number of admin",
      "ru": "Телефонный номер админа",
      "kz": "Admin telefon nomerı"
    },
    "phone_worker": {
      "en": "Phone number of worker",
      "ru": "Телефонный номер работника",
      "kz": "Jūmysşy telefon nömerı"
    },
    "field_cannot_be_empty": {
      "en": "Field can not be an empty",
      "ru": "Поле не может быть пустым",
      "kz": "Örıs bos bola almaidy"
    },
    "send_code": {
      "en": "Send code",
      "ru": "Отправить код",
      "kz": "Kodty jıberu"
    },
    "invalid_phone": {
      "en": "Invalid phone number",
      "ru": "Неправильный номер телефона",
      "kz": "Qate telefon nomerı"
    },
    "invalid_phone_or_code": {
      "en": "Invalid phone number or entered",
      "ru": "Неправильный номер телефона или введенный код",
      "kz": "Telefon nomerı qate nemese engızılgen kod qate"
    },
    "enter_code": {
      "en": "Enter the code",
      "ru": "Введите код",
      "kz": "Kodty engızıŋız"
    },
    "processing": {
      "en": "Processing...",
      "ru": "Обработка...",
      "kz": "Öŋdelude..."
    },
    "loading": {"en": "Loading...", "ru": "Загрузка...", "kz": "Jüktelude..."},
    "error": {"en": "Error", "ru": "Ошибка", "kz": "Qatelık"},
    "enter_sent_sms_come": {
      "en": "Enter the last 4 digits of the incoming call",
      "ru": "Введите последние 4 цифры поступившего звонка",
      "kz": "Kelgen qoŋyraudyŋ soŋğy 4 sanyn engızıŋız"
    },
    "company_name": {
      "en": "Company name",
      "ru": "Название компании",
      "kz": "Kompaniia aty"
    },
    "enter": {"en": "Enter", "ru": "Введите", "kz": "Jazyŋyz"},
    "department": {
      "en": "Company department",
      "ru": "Отдел компании",
      "kz": "Kompaniia bölımı"
    },
    "truancy_price": {
      "en": "Truancy price",
      "ru": "Прогул цена",
      "kz": "Kelmeu bağasy"
    },
    "prize": {"en": "Prize", "ru": "Премия", "kz": "Premiia"},
    "prize_w": {
      "en": "Prize m/u",
      "ru": "Премия мес/ед",
      "kz": "Premiia ai/ed"
    },
    "beg_off": {
      "en": "Asked off price",
      "ru": "Отпросился цена",
      "kz": "Sūranyp alynğan"
    },
    "bef_min": {
      "en": "Before minutes",
      "ru": "До минуты",
      "kz": "Deiın minuttar"
    },
    "email": {"en": "Email", "ru": "Эл. почта", "kz": "El. poşta"},
    "plans": {"en": "Plans", "ru": "Тарифы", "kz": "Tariftar"},
    "general": {"en": "General", "ru": "Общие", "kz": "Jalpy"},
    "postp_min": {
      "en": "Postponement minute",
      "ru": "Отсрочка минуты",
      "kz": "Bastaludan keiın uaqyt"
    },
    "truancy_min": {
      "en": "Truancy minutes",
      "ru": "Прогул минуты",
      "kz": "Kelmeu minuttar"
    },
    "min_price": {
      "en": "Minute price",
      "ru": "Минута цена",
      "kz": "Minut bağasy"
    },
    "aft_min": {
      "en": "After minutes",
      "ru": "После минуты",
      "kz": "Keiın minuttar"
    },
    "change_code": {
      "en": "Change the PIN/fingerprint",
      "ru": "Сменить пароль/отпечаток",
      "kz": "Kodty/sausaq ızdı özgertu"
    },
    "company_created": {
      "en": "Company have been created",
      "ru": "Компания создана",
      "kz": "Kompaniia tırkeldı"
    },
    "some_error_field": {
      "en": "Some fields are entered incorrect",
      "ru": "Некоторые поля введены неверно",
      "kz": "Keibır örıster dūrys engızılmegen"
    },
    "sending_data": {
      "en": "Sending data...",
      "ru": "Отправка данных...",
      "kz": "Aqparattardy jıberu..."
    },
    "success_update": {
      "en": "Success. Please refresh the page",
      "ru": "Успешно. Обновите страницу",
      "kz": "Sättı. Bettı jaŋartyŋyz"
    },
    "save": {"en": "Save", "ru": "Сохранить", "kz": "Saqtau"},
    "loaded": {"en": "Loaded", "ru": "Загружено", "kz": "Jükteldı"},
    "start_workers_list": {
      "en": "This is the beginning of the list of workers",
      "ru": "Начало списка работников",
      "kz": "Jūmysşylar tızımınıŋ bastamasy"
    },
    "end_workers_list": {
      "en": "This is the end fo the list of workers",
      "ru": "Конец списка работников",
      "kz": "Jūmysşylar tızımınıŋ soŋy"
    },
    "error_restart_app": {
      "en": "Something went wrong... Please, restart the app",
      "ru": "Что то пошло не так... Перезапустите приложение",
      "kz": "Bır närse qate boldy... Qosymşany Qaita ıske qosyŋyz "
    },
    "adjustments": {"en": "Adjustments", "ru": "Установки", "kz": "Tüzetuler"},
    "month_results": {
      "en": "The results of the month",
      "ru": "Результаты месяца",
      "kz": "Aidyŋ qorytyndysy"
    },
    1: {"en": "January", "ru": "Январь", "kz": "Qaŋtar"},
    2: {"en": "February", "ru": "Февраль", "kz": "Aqpan"},
    3: {"en": "March", "ru": "Март", "kz": "Nauryz"},
    4: {"en": "April", "ru": "Апрель", "kz": "Säuır"},
    5: {"en": "May", "ru": "Май", "kz": "Mamyr"},
    6: {"en": "June", "ru": "Июнь", "kz": "Mausym"},
    7: {"en": "July", "ru": "Июль", "kz": "Şılde"},
    8: {"en": "August", "ru": "Август", "kz": "Tamyz"},
    9: {"en": "September", "ru": "Сентябрь", "kz": "Qyrküiek"},
    10: {"en": "October", "ru": "Октябрь", "kz": "Qazan"},
    11: {"en": "November", "ru": "Ноябрь", "kz": "Qaraşa"},
    12: {"en": "December", "ru": "Декабрь", "kz": "Jeltoqsan"},
    "Mon": {"en": "mo ", "ru": "пн ", "kz": "ds "},
    "Tue": {"en": "tu ", "ru": "вт ", "kz": "ss "},
    "Wed": {"en": "we ", "ru": "ср ", "kz": "sr "},
    "Thu": {"en": "th ", "ru": "чт ", "kz": "bs "},
    "Fri": {"en": "fr ", "ru": "пт ", "kz": "jm "},
    "Sat": {"en": "sa ", "ru": "сб ", "kz": "sb "},
    "Sun": {"en": "su ", "ru": "вс ", "kz": "jk "},
    "success": {"en": "Success", "ru": "Успешно", "kz": "Sättı"},
    "cant_confirm_worker": {
      "en": "Cannot be confirmed. The worker did not upload the photo",
      "ru": "Нельзя подтвердить. Работник не загрузил фото",
      "kz": "Rastau mümkın emes. Qyzmetker fotosurettı jüktegen joq"
    },
    "pick_geo": {
      "en": "Pick geoposition",
      "ru": "Выберите местоположение",
      "kz": "Oryndy taŋdaŋyz"
    },
    "pick": {"en": "Pick", "ru": "Выбрать", "kz": "Taŋdau"},
    "back": {"en": "Back", "ru": "Назад", "kz": "Artqa"},
    "first_day_of_month": {
      "en": "This is a first day of the month",
      "ru": "Это первый день месяца",
      "kz": "Būl aidyŋ bırınşı künı"
    },
    "first_worker_in_list": {
      "en": "This is a first worker in the list",
      "ru": "Это первый работник в списке",
      "kz": "Tızımnıŋ alğaşqy jūmysyşysy"
    },
    "error_on_date": {
      "en": "Error on date:",
      "ru": "Ошибка на дате:",
      "kz": "Kündegı qate. Kün:"
    },
    "appearance": {"en": "Turnout", "ru": "Явка", "kz": "Kelu"},
    "photo_from_place": {
      "en": "Photo from place",
      "ru": "Фото с точки",
      "kz": "Fotosuret"
    },
    "working_day": {
      "en": "Working day",
      "ru": "Рабочий день",
      "kz": "Jūmys kün"
    },
    "valid_reason": {
      "en": "Valid reason",
      "ru": "Уважительная причина",
      "kz": "Qūrmettı sebep"
    },
    "non_working_day": {
      "en": "Non-working day",
      "ru": "Нерабочий день",
      "kz": "Jūmys emes kün"
    },
    "beg_off_text": {
      "en": "Asked off",
      "ru": "Отпросился",
      "kz": "Sūranylyp kettı"
    },
    "sum_month": {
      "en": "Summary of month",
      "ru": "Сумма месяц",
      "kz": "Ai qorytyndysy"
    },
    "leave": {"en": "Leave", "ru": "Уход", "kz": "Ketu"},
    "here": {"en": "Here", "ru": "Здесь", "kz": "Osy jerde"},
    "repeat": {"en": "Repeat", "ru": "Повтор", "kz": "Qaitalau"},
    "copy": {"en": "Copy", "ru": "Копия", "kz": "Köşıru"},
    "confirmed": {"en": "Confirmed", "ru": "Подтвержден", "kz": "Rastalğan"},
    "confirm": {"en": "Confirm", "ru": "Подтвердить", "kz": "Rastau"},
    "not_confirmed": {
      "en": "Not confirmed",
      "ru": "Не подтвержден",
      "kz": "Rastalmağan"
    },
    "del_worker": {
      "en": "Delete the worker?",
      "ru": "Удалить работника?",
      "kz": "Jūmysşyny öşıru kerek pe?"
    },
    "pick_worker": {
      "en": "Choose a worker",
      "ru": "Выберите работника",
      "kz": "Jūmysşyny taŋdaŋyz"
    },
    "name_con_book": {
      "en": "The name is written as in the phone book",
      "ru": "Имя записан как в телефонной книжке",
      "kz": "Aty telefon kıtapşasyndağydai jazylğan"
    },
    "yes": {"en": "Yes", "ru": "Да", "kz": "İä"},
    "no": {"en": "No", "ru": "Нет", "kz": "Joq"},
    "pls_cumin": {
      "en": "Please, log in",
      "ru": "Пожалуйста, авторизуйтесь",
      "kz": "Jüiege kırıŋız"
    },
    "incorrect_code": {
      "en": "Incorrect code",
      "ru": "Неправильный код",
      "kz": "Qate kod"
    },
    "type_code": {
      "en": "Enter the access code",
      "ru": "Введите код доступа",
      "kz": "Kıru üşın kod engızıŋız"
    },
    "reset_pass": {
      "en": "Reset password",
      "ru": "Сменить пароль",
      "kz": "Qūpiia sözdı özgertu"
    },
    "i_p": {
      "en": "Incorrect password",
      "ru": "Неправильный пароль",
      "kz": "Qūpiia söz qate"
    },
    "enter_new_p": {
      "en": "Enter a new password",
      "ru": "Введите новый пароль",
      "kz": "Jaŋa qūpiia sözdı eŋgızıŋız"
    },
    "enter_currp": {
      "en": "Enter the current password",
      "ru": "Введите текущий пароль",
      "kz": "Qazırgı qūpiia sözdı eŋgızıŋız"
    },
    "choose_plan": {
      "en": "Choose a suitable plan",
      "ru": "Выбрать подходящий тариф",
      "kz": "Qolaily tariftı taŋdaŋyz"
    },
    "3_m": {"en": "3 month", "ru": "3 месяца", "kz": "3 ai"},
    "6_m": {"en": "6 month", "ru": "6 месяцев", "kz": "6 ai"},
    "12_m": {"en": "12 month", "ru": "12 месяцев", "kz": "12 ai"},
    "amount_worker": {
      "en": "Amount of workers",
      "ru": "Количество работников",
      "kz": "Jūmysşylar sany"
    },
    "no_geo_pos": {
      "en": "Geolocation is not given to this day",
      "ru": "Геолокация не присвоена к этому дню",
      "kz": "Būl künge geolokaciia berılmegen"
    },
    "no_appea_time": {
      "en": "No turnout time",
      "ru": "Нет времени явки",
      "kz": "Kelu uaqyty joq"
    },
    "no_leave_time": {
      "en": "No leave time",
      "ru": "Нет времени ухода",
      "kz": "Ketu uaqyty joq"
    },
    "first_send": {
      "en": "First send a photo to the turnout",
      "ru": "Сначала отправьте фотографию на явку",
      "kz": "Aldymen kelu uaqytyna fotosuret jıberıŋız"
    },
    "name": {"en": "Name", "ru": "Имя", "kz": "Aty"},
    "make_photo": {
      "en": "Make a selfie",
      "ru": "Сделать селфи",
      "kz": "Selfige tüsu"
    },
    "no_ass": {
      "en": "No assignment",
      "ru": "Нет установок",
      "kz": "Ornatu joq"
    },
    "on_": {"en": "On time", "ru": "Вовремя", "kz": "Uaqytynda"},
    "late": {"en": "Late", "ru": "Опоздание", "kz": "Keşıgıp kelu"},
    "tr": {"en": "Truancy", "ru": "Прогул", "kz": "Kelmeu"},
    "con": {"en": "Confirming", "ru": "Подтверждение", "kz": "Rastalynu"},
    "min_p": {"en": "Minute price", "ru": "Цена минуты", "kz": "Minut bağasy"},
    "tru_min": {
      "en": "Truancy min/un",
      "ru": "Прогул мин/ед",
      "kz": "Kelmeu min/b"
    },
    "send_photo": {
      "en": "Send the photo",
      "ru": "Отправить фото",
      "kz": "Fotosurettı jıberu"
    },
    "photo_zone": {
      "en": "You are not in the zone for photo",
      "ru": "Вы не находитесь в зоне для фото",
      "kz": "Sız fotosurettı jükteu aimağynda emessız"
    },
    "my_pos": {
      "en": "My geoposition",
      "ru": "Мое местоположение",
      "kz": "Menıŋ ornalasqan jerım"
    },
    "wo_pos": {
      "en": "Work's geoposition",
      "ru": "Местоположение работы",
      "kz": "Jūmys ornalasqan jer"
    },
    "minute": {"en": "min", "ru": "мин", "kz": "min"},
    "ATTENTION": {
      "en":
          "!ATTENTION! Your current month is inactive. The application will work in full functionality only on the 1st of next month!",
      "ru":
          "!ВНИМАНИЕ! Ваш нынешний месяц неактивен.  Приложение заработает во весь функционал только 1 числа следующего месяца!",
      "kz":
          "!NAZAR AUDARYŊYZ! Sızdıŋ qazırgı aiyŋyz belsendı emes. Qoldanba kelesı aidyŋ 1-chisla ğana barlyq funkcionaldylyqta jūmys ısteidı!"
    },
    "ATTENTION_CANT": {
      "en": "ATTENTION Your current month is inactive. Extend the tariff plan.",
      "ru": "ВНИМАНИЕ Ваш нынешний месяц неактивен.  Продлите тарифный план.",
      "kz":
          "Nazar audaryŋyz Sızdıŋ qazırgı aiyŋyz belsendı emes. Tariftık jospardy ūzartyŋyz."
    },
    "atten": {
      "en": "Your current month is inactive",
      "ru": "Ваш нынешний месяц неактивен",
      "kz": "Sızdıŋ qazırgı aiyŋyz belsendı emes"
    },
    "already_exists": {
      "en":
          "The phone number is already registered under another company or is the administrator of another company",
      "ru":
          "Телефонный номер уже зарегистрирован под другую компанию или является админом другой компании",
      "kz":
          "Telefon nömırı basqa kompaniiada tırkelgen nemese basqa kompaniianyŋ adminy bolyp tabylady"
    },
    "today_appear_leave": {
      "en": "Today, turnout/leave",
      "ru": "Сегодня, явка/уход",
      "kz": "Bügın, kelu/ketu"
    },
    "geopoint": {"en": "Geopoint", "ru": "Геоточка", "kz": "Geonükte"},
    "loc_disabled": {
      "en": "Location services are disabled. Please enable the services",
      "ru":
          "Службы определения местоположения отключены. Пожалуйста, включите службы",
      "kz": "Ornalasu qyzmetterı öşırılgen. Qyzmetterdı qosyŋyz"
    },
    "loc_denied": {
      "en": "Location permissions are denied",
      "ru": "В разрешениях на местоположение отказано",
      "kz": "Ornalasqan jerıne rūqsat berılmedı"
    },
    "loc_perm_denied": {
      "en":
          "Location permissions are permanently denied, we cannot request permissions",
      "ru":
          "Разрешения на местоположение постоянно отклоняются, мы не можем запрашивать разрешения",
      "kz":
          "Ornalasuğa rūqsattar ünemı qabyldanbaidy, bız rūqsat sūrai almaimyz"
    },
    "loc_success": {
      "en": "Geolocation received successfully",
      "ru": "Местоположение получено успешно",
      "kz": "Ornalasqan jerı sättı alyndy"
    },
    "itog": {"en": "Total", "ru": "Итог", "kz": "Jalpy"},
    "today_not_w_d": {
      "en": "Today is not working day",
      "ru": "Сегодня не рабочий день",
      "kz": "Bügın jūmys künı emes"
    },
    "photo_time_er": {
      "en": "Too early or too late to send photo",
      "ru": "Слишком рано или слишком поздно чтобы отправлять фото",
      "kz": "Fotosurettı jıberu üşın erte nemese keş"
    },
    "edit_error": {
      "en": "You cannot change the status of the day of today/past dates",
      "ru": "Вы не можете изменять статус дня сегодняшнего/прошедших дат",
      "kz": "Sız bügıngı/ötken künderdıŋ küiın özgerte almaisyz"
    },
    "ok_worker_replace": {
      "en": "The worker will be replaced on the first day of the next month",
      "ru": "Работник будет заменён в первое число следующего месяца",
      "kz": "Qyzmetker kelesı aidyŋ bırınşı künınde auystyrylady"
    },
    "cant_see_tariffs": {
      "en": 'Enter the fields and click the "Save" button',
      "ru": 'Введите поля и нажмите кнопку "Сохранить"',
      "kz": 'Örısterdı engızıp "Saqtau" tüimesın basyŋyz'
    },
  };

  static String get(dynamic key) {
    if (_words[key] != null) {
      if (_words[key]![_localize] != null) {
        return _words[key]![_localize].toString();
      }
    }
    return "";
  }

  static void changeLanguage() {
    if (Localizer._localize == 'kz') {
      Localizer._localize = 'ru';
    } else if (Localizer._localize == 'ru') {
      Localizer._localize = 'en';
    } else {
      Localizer._localize = 'kz';
    }
    saveToSharedPrefs();
  }

  static void saveToSharedPrefs() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString('lang', Localizer._localize);
  }

  static void setLang(String lang) async {
    Localizer._localize = lang;
  }

  static void fetchData() {
    // fetch data with server
    _words = {};
  }
}
