
import 'package:flutter/material.dart';
import 'habit_model.dart';
import 'shared_preferences_manager.dart';

class EditHabitPage extends StatefulWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  final List<IconData> _icons = [
    Icons.star,
    Icons.favorite,
    Icons.work,
    Icons.fitness_center,
    Icons.book,
    Icons.music_note,
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.habit.title;
    _selectedColor = widget.habit.color;
    _selectedIcon = widget.habit.icon;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedHabit = Habit(
        id: widget.habit.id,
        title: _title,
        color: _selectedColor,
        icon: _selectedIcon,
        completedDates: widget.habit.completedDates,
      );
      await SharedPreferencesManager.updateHabit(updatedHabit);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Habit Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 20),
              const Text('Color'),
              Wrap(
                spacing: 10,
                children: _colors
                    .map((color) => ChoiceChip(
                          label: CircleAvatar(backgroundColor: color),
                          selected: _selectedColor == color,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedColor = color;
                              });
                            }
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text('Icon'),
              Wrap(
                spacing: 10,
                children: _icons
                    .map((icon) => ChoiceChip(
                          label: Icon(icon),
                          selected: _selectedIcon == icon,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            }
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
