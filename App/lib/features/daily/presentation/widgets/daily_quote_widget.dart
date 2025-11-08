import 'package:flutter/material.dart';
import 'package:sapit/features/daily/domain/entities/daily_quote.dart';

class DailyQuoteWidget extends StatelessWidget {
  final DailyQuote quote;

  const DailyQuoteWidget({
    super.key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: Colors.amber.shade700, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Quote of the Day',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              quote.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.amber.shade900,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
            if (quote.author != null) ...[
              const SizedBox(height: 12),
              Text(
                '— ${quote.author}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            if (quote.reference != null) ...[
              const SizedBox(height: 4),
              Text(
                quote.reference!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

