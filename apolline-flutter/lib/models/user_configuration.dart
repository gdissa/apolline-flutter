
///Author (Issagha BARRY)
///
class MapFrequency {
  static const int MAP_SYNC_1_MIN = 0;
  static const int MAP_SYNC_5_MIN = 1;
  static const int MAP_SYNC_15_MIN = 2;
  static const int MAP_SYNC_30_MIN = 3;
  static const int MAP_SYNC_1_HOUR = 4;
  static const int MAP_SYNC_3_HOUR = 5;
  static const int MAP_SYNC_6_HOUR = 6;
  static const int MAP_SYNC_12_HOUR = 7;
  static const int MAP_SYNC_24_HOUR = 8;
}

///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  int _mapSyncFrequency ;

  ///
  ///Constructor
  UserConfiguration({mapSyncFrequency: MapFrequency.MAP_SYNC_30_MIN}) {
    this._mapSyncFrequency = mapSyncFrequency;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map json) {
    this._mapSyncFrequency = json['mapSyncFreq'];
  }

  Map<String, dynamic> toJson() {
    return {
      "mapSyncFreq": this.mapSyncFrequency
    };
  }

  ///
  ///getteur map
  int get mapSyncFrequency {
    return this._mapSyncFrequency;
  }

  ///
  ///Setteur
  void set mapSyncFrequency(int frequency) {
    if(frequency >= MapFrequency.MAP_SYNC_1_MIN && frequency <= MapFrequency.MAP_SYNC_24_HOUR) {
      this._mapSyncFrequency = frequency;
    }
  }

}