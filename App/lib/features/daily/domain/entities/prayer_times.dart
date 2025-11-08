class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String date;
  final String hijriDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
  });

  DateTime? getNextPrayerTime() {
    final now = DateTime.now();
    final prayers = [fajr, dhuhr, asr, maghrib, isha];
    
    for (final prayer in prayers) {
      if (prayer.isAfter(now)) {
        return prayer;
      }
    }
    
    return null; // All prayers for today have passed
  }

  String? getNextPrayerName() {
    final now = DateTime.now();
    
    if (fajr.isAfter(now)) return 'Fajr';
    if (dhuhr.isAfter(now)) return 'Dhuhr';
    if (asr.isAfter(now)) return 'Asr';
    if (maghrib.isAfter(now)) return 'Maghrib';
    if (isha.isAfter(now)) return 'Isha';
    
    return null;
  }
}

