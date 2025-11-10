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

  /// Get the current prayer that can be marked as complete
  /// Returns prayer name if within 10 minutes after prayer time
  String? getCurrentCompletablePrayer() {
    final now = DateTime.now();
    const window = Duration(minutes: 10);

    if (now.isAfter(fajr) && now.isBefore(fajr.add(window))) return 'FAJR';
    if (now.isAfter(dhuhr) && now.isBefore(dhuhr.add(window))) return 'DHUHR';
    if (now.isAfter(asr) && now.isBefore(asr.add(window))) return 'ASR';
    if (now.isAfter(maghrib) && now.isBefore(maghrib.add(window)))
      return 'MAGHRIB';
    if (now.isAfter(isha) && now.isBefore(isha.add(window))) return 'ISHA';

    return null;
  }

  /// Get all prayer names
  List<String> getAllPrayerNames() {
    return ['FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA'];
  }

  /// Get prayer time by name
  DateTime? getPrayerTimeByName(String name) {
    switch (name.toUpperCase()) {
      case 'FAJR':
        return fajr;
      case 'DHUHR':
        return dhuhr;
      case 'ASR':
        return asr;
      case 'MAGHRIB':
        return maghrib;
      case 'ISHA':
        return isha;
      default:
        return null;
    }
  }
}
