import 'package:shared_preferences/shared_preferences.dart';

class Localizer {
  static var _localize = 'ru';
  static var _words = {
    "login_as": {
      'en': 'Login as...',
      'ru': 'Войти как...',
      'kz': 'Ретінде кіру...'
    },
    "worker": {'en': 'Worker', 'ru': 'Работник', 'kz': 'Жұмысшы'},
    "admin": {'en': 'Admin', 'ru': 'Админ', 'kz': 'Админ'},
    "fill": {"en": 'Fill', 'ru': 'Заполнить', 'kz': 'Толтыру'},
    "phone_admin": {
      'en': 'Phone number of admin',
      'ru': 'Телефонный номер админа',
      'kz': 'Админ телефон номері',
    },
    "phone_worker": {
      'en': 'Phone number of worker',
      'ru': 'Телефонный номер работника',
      'kz': 'Жұмысшы телефон нөмері',
    },
    "field_cannot_be_empty": {
      'en': 'Field can not be an empty',
      'ru': 'Поле не может быть пустым',
      'kz': 'Өріс бос бола алмайды'
    },
    'send_code': {
      'en': 'Send code',
      'ru': 'Отправить код',
      'kz': 'Кодты жіберу'
    },
    'invalid_phone': {
      'en': 'Invalid phone number',
      'ru': 'Неправильный номер телефона',
      'kz': 'Қате телефон номері'
    },
    'enter_code': {
      'en': 'Enter the code',
      'ru': 'Введите код',
      'kz': 'Кодты енгізіңіз'
    },
    'processing': {
      'en': 'Processing...',
      'ru': 'Обработка...',
      'kz': 'Өңделуде...',
    },
    'loading': {'en': 'Loading...', 'ru': 'Загрузка...', 'kz': 'Жүктелуде...'},
    'error': {
      'en': 'Error',
      'ru': 'Ошибка',
      'kz': 'Қателік',
    },
    'enter_sent_sms_come': {
      'en': 'Enter the code from SMS',
      'ru': 'Введите присланный код с SMS',
      'kz': 'SMS-тен келген кодты енгізіңіз'
    },
    'company_name': {
      'en': 'Company name',
      'ru': 'Название компании',
      'kz': 'Компания аты'
    },
    'enter': {'en': 'Enter', 'ru': 'Введите', 'kz': 'Жазыңыз'},
    'department': {
      'en': 'Company department',
      'ru': 'Отдел компании',
      'kz': 'Компания бөлімі'
    },
    'truancy_price': {
      'en': 'Truancy price',
      'ru': 'Прогул цена',
      'kz': 'Келмеу бағасы'
    },
    'prize': {'en': 'Prize', 'ru': 'Премия', 'kz': 'Премия'},
    'beg_off': {
      'en': 'Asked off price',
      'ru': 'Отпросился цена',
      'kz': 'Сұранып алынған'
    },
    'bef_min': {
      'en': 'Before minutes',
      'ru': 'До минуты',
      'kz': 'Дейін минуттар'
    },
    'email': {'en': 'Email', 'ru': 'Эл. почта', 'kz': 'Эл. пошта'},
    'plans': {'en': 'Plans', 'ru': 'Тарифы', 'kz': 'Тарифтар'},
    'general': {'en': 'General', 'ru': 'Общие', 'kz': 'Жалпы'},
    'postp_min': {
      'en': 'Postponement minute',
      'ru': 'Отсрочка минуты',
      'kz': 'Басталудан кейін уақыт'
    },
    'truancy_min': {
      'en': 'Truancy minutes',
      'ru': 'Прогул минуты',
      'kz': 'Келмеу минуттар'
    },
    'min_price': {
      'en': 'Minute price',
      'ru': 'Минута цена',
      'kz': 'Минут бағасы'
    },
    'aft_min': {
      'en': 'After minutes',
      'ru': 'После минуты',
      'kz': 'Кейін минуттар'
    },
    'change_code': {
      'en': 'Change the PIN/fingerprint',
      'ru': 'Сменить пароль/отпечаток',
      'kz': 'Кодты/саусақ ізді өзгерту'
    },
    'company_created': {
      'en': 'Company have been created',
      'ru': 'Компания создана',
      'kz': 'Компания тіркелді'
    },
    'some_error_field': {
      'en': 'Some fields are entered incorrect',
      'ru': 'Некоторые поля введены неверно',
      'kz': 'Кейбір өрістер дұрыс енгізілмеген'
    },
    'sending_data': {
      'en': 'Sending data...',
      'ru': 'Отправка данных...',
      'kz': 'Ақпараттарды жіберу...'
    },
    'success_update': {
      'en': 'Success. Please refresh the page',
      'ru': 'Успешно. Обновите страницу',
      'kz': 'Сәтті. Бетті жаңартыңыз'
    },
    'save': {'en': 'Save', 'ru': 'Сохранить', 'kz': 'Сақтау'},
    'loaded': {'en': 'Loaded', 'ru': 'Загружено', 'kz': 'Жүктелді'},
    'start_workers_list': {
      'en': 'This is the beginning of the list of workers',
      'ru': 'Начало списка работников',
      'kz': 'Жұмысшылар тізімінің бастамасы'
    },
    'end_workers_list': {
      'en': 'This is the end fo the list of workers',
      'ru': 'Конец списка работников',
      'kz': 'Жұмысшылар тізімінің соңы'
    },
    'error_restart_app': {
      'en': 'Something went wrong... Please, restart the app',
      'ru': 'Что то пошло не так... Перезапустите приложение',
      'kz': 'Бір нәрсе қате болды... Қосымшаны Қайта іске қосыңыз '
    },
    'adjustments': {'en': 'Adjustments', 'ru': 'Установки', 'kz': 'Түзетулер'},
    'month_results': {
      'en': 'The results of the month',
      'ru': 'Результаты месяца',
      'kz': 'Айдың қорытындысы'
    },
    '1': {'en': 'January', 'ru': 'Январь', 'kz': 'Қаңтар'},
    '2': {'en': 'February', 'ru': 'Февраль', 'kz': 'Ақпан'},
    '3': {'en': 'March', 'ru': 'Март', 'kz': 'Наурыз'},
    '4': {'en': 'April', 'ru': 'Апрель', 'kz': 'Сәуір'},
    '5': {'en': 'May', 'ru': 'Май', 'kz': 'Мамыр'},
    '6': {'en': 'June', 'ru': 'Июнь', 'kz': 'Маусым'},
    '7': {'en': 'July', 'ru': 'Июль', 'kz': 'Шілде'},
    '8': {'en': 'August', 'ru': 'Август', 'kz': 'Тамыз'},
    '9': {'en': 'September', 'ru': 'Сентябрь', 'kz': 'Қыркүйек'},
    '10': {'en': 'October', 'ru': 'Октябрь', 'kz': 'Қазан'},
    '11': {'en': 'November', 'ru': 'Ноябрь', 'kz': 'Қараша'},
    '12': {'en': 'December', 'ru': 'Декабрь', 'kz': 'Желтоқсан'},
    'success': {'en': 'Success', 'ru': 'Успешно', 'kz': 'Сәтті'},
    'cant_confirm_worker': {
      'en': 'Cannot be confirmed. The worker did not upload the photo',
      'ru': 'Нельзя подтвердить. Работник не загрузил фото',
      'kz': 'Растау мүмкін емес. Қызметкер фотосуретті жүктеген жоқ'
    },
    'pick_geo': {
      'en': 'Pick geoposition',
      'ru': 'Выберите местоположение',
      'kz': 'Орынды таңдаңыз'
    },
    'pick': {'en': 'Pick', 'ru': 'Выбрать', 'kz': 'Таңдау'},
    'back': {'en': 'Back', 'ru': 'Назад', 'kz': 'Артқа'},
    'first_day_of_month': {
      'en': 'This is a first day of the month',
      'ru': 'Это первый день месяца',
      'kz': 'Бұл айдың бірінші күні'
    },
    'first_worker_in_list': {
      'en': 'This is a first worker in the list',
      'ru': 'Это первый работник в списке',
      'kz': 'Тізімнің алғашқы жұмысышысы'
    },
    'error_on_date': {
      'en': 'Error on date:',
      'ru': 'Ошибка на дате:',
      'kz': 'Күндегі қате. Күн:'
    },
    'appearance': {'en': 'Turnout', 'ru': 'Явка', 'kz': 'Келу'},
    'photo_from_place': {
      'en': 'Photo from place',
      'ru': 'Фото с точки',
      'kz': 'Орындағы фотосурет'
    },
    'working_day': {
      'en': 'Working day',
      'ru': 'Рабочий день',
      'kz': 'Жұмыс күн'
    },
    'valid_reason': {
      'en': "Valid reason",
      'ru': "Уважительная причина",
      'kz': 'Құрметті себеп'
    },
    'non_working_day': {
      'en': 'Non-working day',
      'ru': "Нерабочий день",
      'kz': 'Жұмыс емес күн'
    },
    'beg_off_text': {
      'en': 'Asked off',
      'ru': 'Отпросился',
      'kz': 'Сұранылып кетті'
    },
    'sum_month': {
      'en': 'Summary of month',
      'ru': 'Сумма месяц',
      'kz': 'Ай қорытындысы'
    },
    'leave': {'en': 'Leave', 'ru': 'Уход', 'kz': 'Кету'},
    'here': {'en': 'Here', 'ru': 'Здесь', 'kz': 'Осы жерде'},
    'repeat': {'en': 'Repeat', 'ru': 'Повтор', 'kz': 'Қайталау'},
    'copy': {'en': 'Copy', 'ru': 'Копия', 'kz': 'Көшіру'},
    'confirmed': {'en': 'Confirmed', 'ru': 'Подтвержден', 'kz': 'Расталған'},
    'confirm': {'en': 'Confirm', 'ru': 'Подтвердить', 'kz': 'Растау'},
    'not_confirmed': {
      'en': 'Not confirmed',
      'ru': 'Не подтвержден',
      'kz': 'Расталмаған'
    },
    'ban_the_nigger?': {
      'en': 'Delete the worker?',
      'ru': 'Удалить работника?',
      'kz': 'Жұмысшыны өшіру керек пе?'
    },
    'pick_the_nigger': {
      'en': 'Choose a worker',
      'ru': 'Выберите работника',
      'kz': 'Жұмысшыны таңдаңыз'
    },
    'name_con_book': {
      'en': 'The name is written as in the phone book',
      'ru': 'Имя записан как в телефонной книжке',
      'kz': 'Аты телефон кітапшасындағыдай жазылған'
    },
    'yes': {'en': 'Yes', 'ru': 'Да', 'kz': 'Иә'},
    'no': {'en': 'No', 'ru': 'Нет', 'kz': 'Жоқ'},
    'pls_cumin': {
      'en': 'Please, log in',
      'ru': 'Пожалуйста, авторизуйтесь',
      'kz': 'Жүйеге кіріңіз'
    },
    'incorrect_code': {
      'en': 'Incorrect code',
      'ru': 'Неправильный код',
      'kz': 'Қате код'
    },
    'type_code': {
      'en': 'Enter the access code',
      'ru': 'Введите код доступа',
      'kz': 'Кіру үшін код енгізіңіз'
    },
    'reset_pass': {
      'en': 'Reset password',
      'ru': 'Сменить пароль',
      'kz': 'Құпия сөзді өзгерту'
    },
    'i_p': {
      'en': 'Incorrect password',
      'ru': 'Неправильный пароль',
      'kz': 'Құпия сөз қате'
    },
    'enter_new_p': {
      'en': 'Enter a new password',
      'ru': 'Введите новый пароль',
      'kz': 'Жаңа құпия сөзді еңгізіңіз'
    },
    'enter_currp': {
      'en': 'Enter the current password',
      'ru': 'Введите текущий пароль',
      'kz': 'Қазіргі құпия сөзді еңгізіңіз'
    },
    'choose_plan': {
      'en': 'Choose a suitable plan',
      'ru': 'Выбрать подходящий тариф',
      'kz': 'Қолайлы тарифті таңдаңыз'
    },
    '3_m': {'en': '3 month', 'ru': '3 месяца', 'kz': '3 ай'},
    '6_m': {'en': '6 month', 'ru': '6 месяцев', 'kz': '6 ай'},
    '12_m': {'en': '12 month', 'ru': '12 месяцев', 'kz': '12 ай'},
    'amount_worker': {
      'en': 'Amount of workers',
      'ru': 'Количество работников',
      'kz': 'Жұмысшылар саны'
    },
    'no_geo_pos': {
      'en': 'Geolocation is not given to this day',
      'ru': 'Геолокация не присвоена к этому дню',
      'kz': 'Бұл күнге геолокация берілмеген'
    },
    'no_appea_time': {
      'en': 'No turnout time',
      'ru': 'Нет времени явки',
      'kz': 'Келу уақыты жоқ'
    },
    'no_leave_time': {
      'en': 'No leave time',
      'ru': 'Нет времени ухода',
      'kz': 'Кету уақыты жоқ'
    },
    'first_send': {
      'en': 'First send a photo to the turnout',
      'ru': 'Сначала отправьте фотографию на явку',
      'kz': 'Алдымен келу уақытына фотосурет жіберіңіз'
    },
    'name': {'en': 'Name', 'ru': 'Имя', 'kz': 'Аты'},
    'make_photo': {
      'en': 'Make a photo',
      'ru': 'Сделать фото',
      'kz': 'Суретке түсу'
    },
    'no_ass': {
      'en': 'No assignment',
      'ru': 'Нет установок',
      'kz': 'Орнату жоқ'
    },
    'on_': {'en': 'On time', 'ru': 'Вовремя', 'kz': 'Уақытында'},
    'late': {'en': 'Late', 'ru': 'Опоздание', 'kz': 'Кешігіп келу'},
    'tr': {'en': 'Truancy', 'ru': 'Прогул', 'kz': 'Келмеу'},
    'con': {'en': 'Confirming', 'ru': 'Подтверждение', 'kz': 'Расталыну'},
    'min_p': {'en': 'Minute price', 'ru': 'Цена минуты', 'kz': 'Минут бағасы'},
    'tru_min': {
      'en': 'Truancy min/unit',
      'ru': 'Прогул мин/ед',
      'kz': 'Келмеу мин/бір'
    },
    'send_photo': {
      'en': 'Send the photo',
      'ru': 'Отправить фото',
      'kz': 'Фотосуретті жіберу'
    },
    'photo_zone': {
      'en': 'You are not in the zone for photo',
      'ru': 'Вы не находитесь в зоне для фото',
      'kz': 'Сіз фотосуретті жүктеу аймағында емессіз'
    },
    'my_pos': {
      'en': 'My geoposition',
      'ru': 'Мое местоположение',
      'kz': 'Менің орналасқан жерім'
    },
    'wo_pos': {
      'en': "Work's geoposition",
      'ru': 'Местоположение работы',
      'kz': 'Жұмыс орналасқан жер'
    },
    'minute': {'en': 'min', 'ru': 'мин', 'kz': 'мин'},
    'ATTENTION': {
      'en':
          '!ATTENTION! Your current month is inactive. The application will work in full functionality only on the 1st of next month!',
      'ru':
          '!ВНИМАНИЕ! Ваш нынешний месяц неактивен.  Приложение заработает во весь функционал только 1 числа следующего месяца!',
      'kz':
          '!НАЗАР АУДАРЫҢЫЗ! Сіздің қазіргі айыңыз белсенді емес. Қолданба келесі айдың 1-числа ғана барлық функционалдылықта жұмыс істейді!'
    },
    'ATTENTION_CANT': {
      'en': 'ATTENTION Your current month is inactive. Extend the tariff plan.',
      'ru': 'ВНИМАНИЕ Ваш нынешний месяц неактивен.  Продлите тарифный план.',
      'kz':
          'Назар аударыңыз Сіздің қазіргі айыңыз белсенді емес. Тарифтік жоспарды ұзартыңыз.'
    },
    'atten': {
      'en': 'Your current month is inactive',
      'ru': 'Ваш нынешний месяц неактивен',
      'kz': 'Сіздің қазіргі айыңыз белсенді емес'
    }
  };

  static String get(String key) {
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
