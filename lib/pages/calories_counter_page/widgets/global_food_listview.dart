import 'package:discipline_plus/pages/calories_counter_page/widgets/food_quantity_selector.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';
import '../../../widget/edit_delete_option_menu.dart';

class GlobalFoodList extends StatefulWidget {
  final String searchQuery;
  final Stream<List<DietFood>> stream;
  final Function(DietFood food) onEdit;
  final Function(DietFood food) onDeleted;
  final Function(double oldValue, double newValue, DietFood food) onQuantityChange;



  GlobalFoodList(
      {super.key,
      this.searchQuery = '',
      Stream<List<DietFood>>? stream,
      required this.onEdit,
      required this.onDeleted,
      required this.onQuantityChange,})
      : stream = stream ?? _defaultDummyStream;

  static final Stream<List<DietFood>> _defaultDummyStream = Stream.value([
    DietFood(id: '1', name: 'Apple', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '2', name: 'Banana', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '3', name: 'Boiled Egg', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '4', name: 'Oats', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '5', name: 'Milk', foodStats: FoodStats.empty(), time: DateTime.now()),
  ]);

  @override
  State<GlobalFoodList> createState() => _GlobalFoodListState();
}

class _GlobalFoodListState extends State<GlobalFoodList> {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DietFood>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<DietFood>? foods = snapshot.data;
        if (foods == null || foods.isEmpty) {
          return const Center(child: Text('No items yet'));
        }

        // // Filter locally
        final filtered = foods.where((f) {
          return f.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No matching items'));
        }

        return ListView.separated(
          key: ValueKey(foods.length),
          physics: const BouncingScrollPhysics(),
          // itemCount: foods.length,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            // final food = foods[index];
            final food = filtered[index];
            final barColor = Constants.colorPalette[index % Constants.colorPalette.length];

            return _FoodCard(
                key: ValueKey(food.id),
                food: food,
                barColor: barColor,
                onQuantityChange: widget.onQuantityChange,
                editDeleteOptionMenu: EditDeleteOptionMenu(
                    onEdit: () {
                      widget.onEdit(food);
                    },
                    onDelete: () {
                      widget.onDeleted(food);
                    }),

                );
          },
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final DietFood food;
  final Color barColor;
  final Function(double oldValue, double newValue, DietFood dietFood) onQuantityChange;
  final EditDeleteOptionMenu editDeleteOptionMenu;

  const _FoodCard({
    super.key,
    required this.food,
    required this.barColor,
    required this.onQuantityChange, required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 5,
          child: Row(
            children: [
              // colored bar
              Container(width: 10, height: 64, color: barColor),
              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${food.foodStats.calories} kcal',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (food.count > 1)
                            Text(
                              ' (total:${(food.foodStats.calories * food.count).toInt()})',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),



              editDeleteOptionMenu,
              // Builder(
              //   builder: (buttonContext) {
              //
              //
              //     return IconButton(
              //       onPressed: () {
              //         onClickOptionMenu(buttonContext);
              //       },
              //       icon: Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
              //     );
              //
              //
              //   },
              // ),
              FoodQuantitySelector(
                initialValue: food.count.toDouble(),
                onChanged: (oldValue, newValue) {
                  onQuantityChange(oldValue, newValue, food);
                },
              ),

              SizedBox(
                width: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
