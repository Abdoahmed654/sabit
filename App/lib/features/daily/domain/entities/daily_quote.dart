class DailyQuote {
  final String id;
  final String text;
  final String? author;
  final String? reference;
  final String category;
  final DateTime date;

  DailyQuote({
    required this.id,
    required this.text,
    this.author,
    this.reference,
    required this.category,
    required this.date,
  });
}

