import 'package:hive/hive.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

//Для работы необходимо инициализировать box settingsBox в main.dart
class SettingsDatabase {
  static Future<void> setTheme(bool value) async{
    final Box<dynamic> box = Hive.box('settingsBox');
    await box.put("isDarkTheme", value);
  }

  static Future<bool> getTheme() async{
    final Box<dynamic> box = Hive.box('settingsBox');
    bool value = box.get("isDarkTheme", defaultValue: true);
    return value;
  }

  static bool getThemeBox() {
    final Box<dynamic> box = Hive.box('settingsBox');
    final bool isDark;
    isDark = box.get('isDarkTheme', defaultValue: true);
    return isDark;
  }

  static Future<void> setTable(ScheduleTable table) async{
    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    await box.put("table", table);
  }

  static ScheduleTable? getTable() {
    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    ScheduleTable? table = box.get("table", defaultValue: null);
    return table;
  }

  static Future<void> closeBox() async{
    await Hive.box('settingsBox').close();
  }

  static Future<void> addFavoriteGroup(String groupName) async{
    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
   
    List<String> listGroupName = _setGroupList();
    List<String> listFavorites = box.get("favoriteGroupList", defaultValue: listGroupName);
    Set <String> setFavorites = Set.from(listFavorites);
    if (!setFavorites.contains(groupName)){
      listFavorites.add(groupName);
      await box.put("favoriteGroupList", listFavorites);
    }
  }

  static List<String> getFavoriteGroupList() {
    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    List<String> listGroupName = _setGroupList();
    
    List<String> listFavorites = box.get("favoriteGroupList", defaultValue: listGroupName);
    return listFavorites;
  }

  static Future<void> deleteFavoriteGroup(String groupName) async{
     if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    List<String> listGroupName = _setGroupList();
    List<String> listFavorites = box.get("favoriteGroupList", defaultValue: listGroupName);
  listFavorites.remove(groupName);
    await box.put("favoriteGroupList", listFavorites);
  }

  static List<String> _setGroupList(){
    String? groupName = getTable()?.groupName;
    List<String> listGroupName = [];
    if (groupName != null) {
      listGroupName.add(groupName);
    }
    return listGroupName;
  }

  static bool isFavoriteGroup(String groupName) {
    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    List<String> listGroupName = _setGroupList();
    List<String> listFavorites = box.get("favoriteGroupList", defaultValue: listGroupName);
    for (String group in listFavorites) {
      if(group == groupName){
        return true;
      }
    }
    return false;
  }

  static clear() async{
   if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    final Box<dynamic> box = Hive.box('settingsBox');
    await box.clear();
  }

}