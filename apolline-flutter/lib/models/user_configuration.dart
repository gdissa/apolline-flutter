
///Author (Issagha BARRY)
///
enum MapFrequency {
  MAP_SYNC_1_MIN,
  MAP_SYNC_5_MIN,
  MAP_SYNC_15_MIN,
  MAP_SYNC_30_MIN,
  MAP_SYNC_1_HOUR,
  MAP_SYNC_3_HOUR,
  MAP_SYNC_6_HOUR,
  MAP_SYNC_12_HOUR,
  MAP_SYNC_24_HOUR
}

///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  MapFrequency _mapSyncFrequency ;

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
  MapFrequency get mapSyncFrequency {
    return this._mapSyncFrequency;
  }

  ///
  ///Setteur
  void set mapSyncFrequency(MapFrequency frequency) {
    this._mapSyncFrequency = frequency;
  }

}