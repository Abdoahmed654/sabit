import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_event.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_state.dart';
import 'package:sapit/features/daily/domain/entities/fasting_completion.dart';

class FastingCard extends StatefulWidget {
  final GoodDeedsBloc bloc;

  const FastingCard({
    super.key,
    required this.bloc,
  });

  @override
  State<FastingCard> createState() => _FastingCardState();
}

class _FastingCardState extends State<FastingCard> {
  FastingType _selectedType = FastingType.voluntary;
  bool _showDetails = false;

  String _fastingTypeToString(FastingType type) {
    switch (type) {
      case FastingType.voluntary:
        return 'VOLUNTARY';
      case FastingType.monday:
        return 'MONDAY';
      case FastingType.thursday:
        return 'THURSDAY';
      case FastingType.whiteDays:
        return 'WHITE_DAYS';
      case FastingType.arafah:
        return 'ARAFAH';
      case FastingType.ashura:
        return 'ASHURA';
      case FastingType.shawwal:
        return 'SHAWWAL';
    }
  }

  String _fastingTypeLabel(FastingType type) {
    switch (type) {
      case FastingType.voluntary:
        return 'Voluntary';
      case FastingType.monday:
        return 'Monday';
      case FastingType.thursday:
        return 'Thursday';
      case FastingType.whiteDays:
        return 'White Days';
      case FastingType.arafah:
        return 'Arafah';
      case FastingType.ashura:
        return 'Ashura';
      case FastingType.shawwal:
        return 'Shawwal';
    }
  }

  void _submitFasting() {
    final fastingTypeString = _fastingTypeToString(_selectedType);
    widget.bloc.add(CompleteFastingEvent(fastingTypeString));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoodDeedsBloc, GoodDeedsState>(
      bloc: widget.bloc,
      builder: (context, state) {
        bool canSubmit = false;
        bool completedToday = false;
        String? message;

        if (state is FastingStatusLoaded) {
          canSubmit = state.status.canSubmit;
          completedToday = state.status.completedToday;
          message = state.status.message;
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // Header
              InkWell(
                onTap: () {
                  setState(() {
                    _showDetails = !_showDetails;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: _showDetails
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          )
                        : BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.nightlight_round,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fasting',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              completedToday
                                  ? 'Completed for today ✓'
                                  : 'Record your fasting',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (completedToday)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        )
                      else
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),

              // Expanded Details
              if (_showDetails && !completedToday)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status Message
                      if (!canSubmit && message != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Fasting Type Selection
                      const Text(
                        'Select Fasting Type:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: FastingType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(_fastingTypeLabel(type)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                            selectedColor: const Color(0xFF6A11CB),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Rewards Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '100 XP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '50 Coins',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Submit Button
                      ElevatedButton(
                        onPressed: canSubmit ? _submitFasting : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: const Text(
                          'SUBMIT FASTING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

