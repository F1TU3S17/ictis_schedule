String? currentTime(dynamic now){
    String str = "";
    if (now.hour < 4){
      str = "Доброй ночи!";
      return str;
    }
    if (now.hour < 12){
      str = "Доброе утро!";
      return str;
    }
    if (now.hour < 18){
      str = "Добрый день!";
      return str;
    }
    if (now.hour < 24){
      str = "Добрый вечер!";
      return str;
    }
    return null;
  }