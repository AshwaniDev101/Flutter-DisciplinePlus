import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  _DietPageState createState() => _DietPageState();
}

class Food {
  final String name;
  final int kcal;
  final int quantity;
  final String mealType;
  final DateTime time;

  Food(this.name, this.kcal, this.quantity, this.mealType, this.time);
}

class _DietPageState extends State<DietPage> {
  // Progress tracking
  double _progress = 0;
  final double _maxProgress = 1500;

  // Date and pagination
  final DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  // Food lists
  final List<Food> _foodList = [
    Food('Apple', 95, 1, 'Breakfast', DateTime.now()),
    Food('Grilled Chicken', 250, 1, 'Lunch', DateTime.now()),
    Food('Salad', 150, 1, 'Dinner', DateTime.now()),
  ];
  final List<Food> _foodEatenList = [];

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  void _updateProgress() {
    final total = _foodEatenList.fold<int>(0, (sum, f) => sum + f.kcal * f.quantity);
    setState(() => _progress = total.toDouble());
  }

  void _moveItem(int index, bool fromEaten) {
    setState(() {
      if (fromEaten) {
        final item = _foodEatenList.removeAt(index);
        _foodList.add(item);
      } else {
        final item = _foodList.removeAt(index);
        _foodEatenList.add(item);
      }
      _updateProgress();
    });
  }

  void _onHeaderSwipe(DragUpdateDetails details) {
    if (details.delta.dx < -10 && _currentIndex < 1) {
      _goToPage(_currentIndex + 1);
    } else if (details.delta.dx > 10 && _currentIndex > 0) {
      _goToPage(_currentIndex - 1);
    }
  }

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Color _getProgressColor() {
    final ratio = _progress / _maxProgress;
    if (ratio < 0.6) return Colors.green;
    if (ratio < 0.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.calendar_today),
      //       onPressed: () async {
      //         final date = await showDatePicker(
      //           context: context,
      //           initialDate: _selectedDate,
      //           firstDate: DateTime(2000),
      //           lastDate: DateTime(2100),
      //         );
      //         if (date != null) setState(() => _selectedDate = date);
      //       },
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          // Header with progress + swipe/tap control

          SafeArea(child: Text("")),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: _onHeaderSwipe,
            child: Column(
              children: [
                Container(
                  // color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderTab('Food', 0),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 130, // Increased from 150
                            width: 130,  // Increased from 150
                            child: CircularProgressIndicator(
                              value: _progress / _maxProgress,
                              strokeWidth: 15, // Increased from 10
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_progress.toInt()}',
                                style: const TextStyle(
                                  fontSize: 32, // Increased from 20
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/ ${_maxProgress.toInt()} kcal',
                                style: TextStyle(
                                  fontSize: 16, // Increased from 12
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildHeaderTab('Eaten', 1),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fat: 100g", style: TextStyle(fontSize: 12),),
                      Text("Nutrition: 130g", style: TextStyle(fontSize: 12),),
                      Text("Curbs: 220g", style: TextStyle(fontSize: 12),),
                    ],),
                ),
              ],
            ),



          ),


          // PageView content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildListView(_foodList, false),
                _buildListView(_foodEatenList, true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderTab(String label, int index) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.blue : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildListView(List<Food> list, bool isEaten) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Dismissible(
          key: Key(item.hashCode.toString()),
          background: Container(color: Colors.redAccent),
          onDismissed: (_) => _moveItem(index, isEaten),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(_iconForMeal(item.mealType)),
              title: Text(item.name),
              subtitle: Text(
                  '${item.kcal * item.quantity} kcal (${item.quantity}x)'),
              trailing: Text(DateFormat('HH:mm').format(item.time)),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForMeal(String type) {
    switch (type) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  void _showAddFoodDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', calories = '', quantity = '1', mealType = 'Breakfast';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Food'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: mealType,
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => mealType = v!,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Food Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => name = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => calories = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => quantity = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                setState(() {
                  final food = Food(
                    name,
                    int.parse(calories),
                    int.parse(quantity),
                    mealType,
                    DateTime.now(),
                  );
                  _foodList.add(food);
                  _updateProgress();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
