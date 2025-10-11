import 'package:discipline_plus/pages/calories_counter_page/food_manager.dart';
import 'package:discipline_plus/pages/calories_counter_page/widgets/food_quantity_selector.dart';
import 'package:flutter/material.dart';
import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';

class GlobalFoodList extends StatelessWidget {

  final Stream<List<DietFood>> stream;
  final Function(DietFood food) onEdit;
  final Function(DietFood food) onDeleted;



  GlobalFoodList({
    Key? key,
    Stream<List<DietFood>>? stream, required this.onEdit, required this.onDeleted,

  })  : stream = stream ?? _defaultDummyStream,
        super(key: key);

  static final Stream<List<DietFood>> _defaultDummyStream = Stream.value([
    DietFood(id: '1', name: 'Apple', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '2', name: 'Banana', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '3', name: 'Boiled Egg', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '4', name: 'Oats', foodStats: FoodStats.empty(), time: DateTime.now()),
    DietFood(id: '5', name: 'Milk', foodStats: FoodStats.empty(), time: DateTime.now()),
  ]);

  final List<Color> _colorPalette = const [
    Color(0xFFF8BBD0),
    Color(0xFFBBDEFB),
    Color(0xFFC8E6C9),
    Color(0xFFE1BEE7),
    Color(0xFFB2DFDB),
    Color(0xFFFFECB3),
    Color(0xFFFFE0B2),
    Color(0xFFC5CAE9),
    Color(0xFFB2EBF2),
    Color(0xFFFFCDD2),
    Color(0xFFDCEDC8),
    Color(0xFFFFF9C4),
    Color(0xFFD1C4E9),
    Color(0xFFB3E5FC),
    Color(0xFFFFCCBC),
    Color(0xFFE6EE9C),
    Color(0xFFCFD8DC),
    Color(0xFFF3E5F5),
    Color(0xFFEF9A9A),
    Color(0xFFBCAAA4),
    Color(0xFFFFF3E0),
    Color(0xFFA1887F),
    Color(0xFF8D6E63),
    Color(0xFF6D4C41),
    Color(0xFFFFE082),
    Color(0xFFFFCC80),
    Color(0xFFD7CCC8),
    Color(0xFFFF5252),
    Color(0xFFFFA726),
    Color(0xFFFFEB3B),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFF7E57C2),
    Color(0xFF29B6F6),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
  ];


  void _showItemMenu(BuildContext buttonContext, DietFood food) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(buttonContext)!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: buttonContext,
      position: position,
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'edit') {
        onEdit(food);
      } else if (value == 'delete') {
        onDeleted(food);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DietFood>>(
      stream: stream,
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

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: ListView.separated(
              
              physics: BouncingScrollPhysics(),
              itemCount: foods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final food = foods[index];
                final barColor = _colorPalette[index % _colorPalette.length];
            
                return _FoodCard(
                  food: food,
                  barColor: barColor,
                  onClickOptionMenu: (context) => _showItemMenu(context, food),
                  onAddPressed: () {
                    // Implement add-food logic
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final DietFood food;
  final Color barColor;
  final void Function(BuildContext buttonContext) onClickOptionMenu;
  final VoidCallback? onAddPressed;

  const _FoodCard({
    Key? key,
    required this.food,
    required this.barColor,
    required this.onClickOptionMenu,
    this.onAddPressed,
  }) : super(key: key);

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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${food.foodStats.calories} kcal',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),


              Builder(
                builder: (buttonContext) {
                  return IconButton(
                    onPressed: () {
                      onClickOptionMenu(buttonContext);
                    },
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey, size: 24),
                  );
                },
              ),
              FoodQuantitySelector(initialValue:food.count.toDouble(),onChanged: (oldValue,newValue){



                if (newValue > oldValue) {
                  FoodManager.instance.addToConsumedFood(food.foodStats, food);
                } else if (newValue < oldValue) {
                  FoodManager.instance.subtractFromConsumedFood(food.foodStats, food);
                }


              },),

              SizedBox(width: 14,),


            ],
          ),
        ),
      ),
    );
  }
}
