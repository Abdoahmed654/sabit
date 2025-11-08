import 'package:sapit/features/daily/domain/entities/daily_quote.dart';

class DailyQuoteModel extends DailyQuote {
  DailyQuoteModel({
    required super.id,
    required super.text,
    super.author,
    super.reference,
    required super.category,
    required super.date,
  });

  factory DailyQuoteModel.fromJson(Map<String, dynamic> json) {
    return DailyQuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String?,
      reference: json['reference'] as String?,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'reference': reference,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}

