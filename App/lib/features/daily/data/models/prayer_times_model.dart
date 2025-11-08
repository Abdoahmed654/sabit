import 'package:sapit/features/daily/domain/entities/prayer_times.dart';

class PrayerTimesModel extends PrayerTimes {
  PrayerTimesModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.date,
    required super.hijriDate,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as String;
    
    return PrayerTimesModel(
      fajr: _parseTime(date, timings['Fajr'] as String),
      sunrise: _parseTime(date, timings['Sunrise'] as String),
      dhuhr: _parseTime(date, timings['Dhuhr'] as String),
      asr: _parseTime(date, timings['Asr'] as String),
      maghrib: _parseTime(date, timings['Maghrib'] as String),
      isha: _parseTime(date, timings['Isha'] as String),
      date: date,
      hijriDate: json['hijriDate'] as String? ?? '',
    );
  }

  static DateTime _parseTime(String date, String time) {
    // Remove timezone info if present (e.g., "05:30 (EET)")
    final cleanTime = time.split(' ')[0];
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final dateTime = DateTime.parse(date);
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hour,
      minute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timings': {
        'Fajr': _formatTime(fajr),
        'Sunrise': _formatTime(sunrise),
        'Dhuhr': _formatTime(dhuhr),
        'Asr': _formatTime(asr),
        'Maghrib': _formatTime(maghrib),
        'Isha': _formatTime(isha),
      },
      'date': date,
      'hijriDate': hijriDate,
    };
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

