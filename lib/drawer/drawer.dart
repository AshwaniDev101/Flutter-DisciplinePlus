import 'package:discipline_plus/_archive/habit_tracker_page/habit_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/habit_tracker_page/habit_tracker_page.dart';
import '../pages/schedule_page/schedule_page.dart';
import '../pages/schedule_page/viewModel/schedule_view_model.dart';
import '../_archive/temp/note_app.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext) routeBuilder;

  DrawerItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.routeBuilder,
  });
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <DrawerItem>[
      DrawerItem(
        title: 'Initiative Planner',
        icon: Icons.event_note_rounded,
        color: Colors.indigoAccent.shade100,
        routeBuilder: (ctx) => ChangeNotifierProvider(
          create: (_) => ScheduleViewModel(),
          child: const SchedulePage(),
        ),
      ),
      DrawerItem(
        title: 'Log Note',
        icon: Icons.sticky_note_2_rounded,
        color: Colors.amber.shade200,
        routeBuilder: (ctx) => NoteApp(),
      ),
      DrawerItem(
        title: 'Habit Tracker',
        icon: Icons.track_changes,
        color: Colors.teal.shade200,
        routeBuilder: (ctx) => const HabitApp(),
      ),
      DrawerItem(
        title: 'Settings',
        icon: Icons.settings_rounded,
        color: Colors.grey.shade400,
        routeBuilder: (ctx) => const Scaffold(body: Center(child: Text('Settings (placeholder)'))),
      ),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 1,
      width: 300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // User Info Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.shade50,
                      border: Border.all(color: Colors.teal.shade100, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'AY',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Ashwani Yadav',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ashwani10101@gmail.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _StatItem(label: 'Habits', value: '12', color: Colors.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatItem(label: 'Tasks', value: '5', color: Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatItem(label: 'Notes', value: '8', color: Colors.indigo)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Future.microtask(() {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => item.routeBuilder(context)),
                          );
                        });
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color.withValues(alpha: 1), size: 22),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: Colors.transparent,
                      hoverColor: Colors.grey.shade50,
                    ),
                  );
                },
              ),
            ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _FooterButton(
                    icon: Icons.dark_mode_outlined,
                    label: 'Theme',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Log Out'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade100),
                        foregroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
}
