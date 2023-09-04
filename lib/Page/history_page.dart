import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_food_app/model/food_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<FoodItem> foodItems = [];
  bool dataLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() {
    var uid = auth.currentUser!.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('history/$uid');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        foodItems = data.entries.map((entry) {
          final itemData = entry.value as Map<dynamic, dynamic>;
          final name = itemData['name'];
          final total = itemData['total'];
          final image = itemData['image'];
          final price = itemData['price'];
          return FoodItem(name: name, price: price, image: image, total: total);
        }).toList();
        setState(() {
          dataLoaded = !dataLoaded;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: Visibility(
        visible: dataLoaded,
        replacement: const Center(child: Text('No history payment')),
        child: Container(
          margin: const EdgeInsets.all(5),
          child: ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(foodItems[index].name),
                          Text(
                              '\$${foodItems[index].price * foodItems[index].total!}')
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${foodItems[index].total}x'),
                      ElevatedButton(onPressed: () {}, child: Text('Buy Again'))
                    ],
                  ),
                  leading: Image.network(foodItems[index].image),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
