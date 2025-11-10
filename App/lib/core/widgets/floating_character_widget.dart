import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';

class FloatingCharacterWidget extends StatefulWidget {
  const FloatingCharacterWidget({super.key});

  @override
  State<FloatingCharacterWidget> createState() => _FloatingCharacterWidgetState();
}

class _FloatingCharacterWidgetState extends State<FloatingCharacterWidget> {
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(0.0, screenSize.width - 80),
                  (_position.dy + details.delta.dy).clamp(0.0, screenSize.height - 80),
                );
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
                // Snap to nearest edge
                _position = _snapToEdge(screenSize);
              });
            },
            onTap: () {
              // Navigate to character screen
              context.push('/character');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isDragging ? 0.4 : 0.2),
                    blurRadius: _isDragging ? 20 : 10,
                    spreadRadius: _isDragging ? 2 : 0,
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  // Character Avatar
                  Center(
                    child: Text(
                      user.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Level Badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        'Lv${user.level}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Pulse animation when not dragging
                  if (!_isDragging)
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(1 - value),
                                width: 2,
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _snapToEdge(Size screenSize) {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    // Determine which edge is closest
    final distanceToLeft = _position.dx;
    final distanceToRight = screenSize.width - _position.dx - 80;
    final distanceToTop = _position.dy;
    final distanceToBottom = screenSize.height - _position.dy - 80;
    
    final minDistance = [
      distanceToLeft,
      distanceToRight,
      distanceToTop,
      distanceToBottom,
    ].reduce((a, b) => a < b ? a : b);
    
    // Snap to the closest edge
    if (minDistance == distanceToLeft) {
      // Snap to left edge
      return Offset(20, _position.dy);
    } else if (minDistance == distanceToRight) {
      // Snap to right edge
      return Offset(screenSize.width - 100, _position.dy);
    } else if (minDistance == distanceToTop) {
      // Snap to top edge
      return Offset(_position.dx, 20);
    } else {
      // Snap to bottom edge
      return Offset(_position.dx, screenSize.height - 100);
    }
  }
}

