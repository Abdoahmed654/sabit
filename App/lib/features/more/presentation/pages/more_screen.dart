import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_event.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/core/theme/theme_cubit.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(
              child: Text('Please login to access this section'),
            );
          }

          final user = state.user;

          return ListView(
            children: [
              // User Profile Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.displayName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatChip(
                                Icons.star,
                                'Level ${user.level}',
                                Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                Icons.bolt,
                                '${user.xp} XP',
                                Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                Icons.monetization_on,
                                '${user.coins}',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.leaderboard,
                title: 'Leaderboard',
                subtitle: 'See top players',
                onTap: () => context.push('/leaderboard'),
              ),
              _buildMenuItem(
                context,
                icon: Icons.shopping_bag,
                title: 'Shop',
                subtitle: 'Buy items with coins',
                onTap: () => context.push('/shop'),
              ),
              _buildMenuItem(
                context,
                icon: Icons.person,
                title: 'Character',
                subtitle: 'Customize your avatar',
                onTap: () => context.push('/character'),
              ),
              // Theme selection (Light / Dark / System)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.brightness_6,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text(
                  'Theme',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Choose light, dark or system theme'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final ThemeMode current = context.read<ThemeCubit>().state;

                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      ThemeMode selected = current;
                      return StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          title: const Text('Select Theme'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.system,
                                groupValue: selected,
                                title: const Text('System'),
                                onChanged: (v) => setState(() => selected = v!),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.light,
                                groupValue: selected,
                                title: const Text('Light'),
                                onChanged: (v) => setState(() => selected = v!),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.dark,
                                groupValue: selected,
                                title: const Text('Dark'),
                                onChanged: (v) => setState(() => selected = v!),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ThemeCubit>().setTheme(selected);
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Theme updated'),
                                  ),
                                );
                              },
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                iconColor: Colors.red,
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
