import 'package:flutter/material.dart';
import '../../models/diet_food.dart';
import '../../models/food_stats.dart';
import '../../core/utils/helper.dart';
import 'food_manager.dart'; // assuming generateReadableTimestamp is here

class AddEditDietFoodDialog {



  /// Opens the Add/Edit DietFood Dialog
  static void show(BuildContext context, {DietFood? food, required Function(DietFood dietfood) onAdd}) {
    final formKey = GlobalKey<FormState>();

    // Pre-fill values if editing
    String name = food?.name ?? '';
    String calories = food?.foodStats.calories.toString() ?? '';
    String quantity = food?.count.toString() ?? '1';
    String proteins = food?.foodStats.proteins.toString() ?? '0';
    String carbohydrates = food?.foodStats.carbohydrates.toString() ?? '0';
    String fats = food?.foodStats.fats.toString() ?? '0';
    String vitamins = food?.foodStats.vitamins.toString() ?? '0';
    String minerals = food?.foodStats.minerals.toString() ?? '0';

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            food == null ? 'Add New Diet Food' : 'Edit Diet Food',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: buildInputDecoration('Food Name'),
                  style: const TextStyle(fontSize: 14),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => name = v!,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: calories,
                        decoration: buildInputDecoration('Calories'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => calories = v!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: quantity,
                        decoration: buildInputDecoration('Quantity'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => quantity = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nutritional Values (per serving)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildNutrientField('Proteins', proteins, (v) => proteins = v!),
                    _buildNutrientField('Carbs', carbohydrates, (v) => carbohydrates = v!),
                    _buildNutrientField('Fats', fats, (v) => fats = v!),
                    _buildNutrientField('Vitamins', vitamins, (v) => vitamins = v!),
                    _buildNutrientField('Minerals', minerals, (v) => minerals = v!),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),


          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final updatedDietFood = DietFood(
                  id: food?.id ?? generateReadableTimestamp(),
                  name: name,
                  count: int.parse(quantity),
                  time: DateTime.now(),
                  foodStats: FoodStats(
                    proteins: int.parse(proteins),
                    carbohydrates: int.parse(carbohydrates),
                    fats: int.parse(fats),
                    vitamins: int.parse(vitamins),
                    minerals: int.parse(minerals),
                    calories: int.parse(calories),
                  ),
                );

                onAdd(updatedDietFood);

                Navigator.of(context).pop();
              }
            },
            child: Text(
              food == null ? 'ADD' : 'SAVE',
              style: const TextStyle(fontSize: 13),
            ),
          ),

          // ElevatedButton(
          //   onPressed: () {
          //     if (formKey.currentState!.validate()) {
          //       formKey.currentState!.save();
          //
          //       final updatedDietFood = DietFood(
          //         id: food?.id ?? generateReadableTimestamp(),
          //         name: name,
          //         count: int.parse(quantity),
          //         time: DateTime.now(),
          //         foodStats: FoodStats(
          //           proteins: int.parse(proteins),
          //           carbohydrates: int.parse(carbohydrates),
          //           fats: int.parse(fats),
          //           vitamins: int.parse(vitamins),
          //           minerals: int.parse(minerals),
          //           calories: int.parse(calories),
          //         ),
          //       );
          //
          //       if (food == null) {
          //         FoodManager.instance.addToAvailableFood(updatedDietFood);
          //       } else {
          //         FoodManager.instance.editAvailableFood(updatedDietFood);
          //       }
          //
          //       Navigator.of(context).pop();
          //     }
          //   },
          //   child: Text(
          //     food == null ? 'ADD' : 'SAVE',
          //     style: const TextStyle(fontSize: 13),
          //   ),
          // ),
        ],
      ),
    );
  }

  static Widget _buildNutrientField(
      String label, String value, Function(String?) onSaved) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 11, color: Colors.grey[700]),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        onSaved: onSaved,
        validator: (v) => v!.isEmpty ? 'Req' : null,
      ),
    );
  }
}
