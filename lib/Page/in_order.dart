import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_food_app/model/food_model.dart';

class InOrderPage extends StatefulWidget {
  const InOrderPage({super.key});

  @override
  State<InOrderPage> createState() => _InOrderPageState();
}

class _InOrderPageState extends State<InOrderPage> {
  DatabaseReference? dbRef;
  DatabaseReference? dbHistory;
  int randomNum = Random().nextInt(999);
  FirebaseAuth auth = FirebaseAuth.instance;
  List<FoodItem> foodItems = [];
  bool dataLoad = false;
  bool orderBtn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() {
    dbRef = FirebaseDatabase.instance.ref('inOrder/${auth.currentUser!.uid}');
    dbRef!.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        foodItems = data.entries.map((entry) {
          final itemData = entry.value as Map<dynamic, dynamic>;
          final name = itemData['name'];
          final total = itemData['total'];
          final image = itemData['image'];
          final price = itemData['price'];
          final status = itemData['status'];

          return FoodItem(
              name: name,
              price: price,
              image: image,
              total: total,
              status: status);
        }).toList();
        setState(() {
          dataLoad = true;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In Order'),
      ),
      body: Visibility(
        visible: dataLoad,
        replacement: Center(
          child: Text('No order'),
        ),
        child: ListView.builder(
          itemCount: foodItems.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                onTap: () {
                  setState(() {
                    orderBtn = !orderBtn;
                    foodItems[index].orderBtn = orderBtn;
                    debugPrint('Button is $orderBtn');
                  });
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(foodItems[index].name),
                    Column(
                      children: [
                        Text('Status'),
                        Text(
                          '${foodItems[index].status}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${foodItems[index].total.toString()}x'),
                    Visibility(
                        visible: foodItems[index].orderBtn!,
                        child: ElevatedButton(
                            onPressed: () async {
                              dbHistory = await FirebaseDatabase.instance.ref(
                                  'history/${auth.currentUser!.uid}/${foodItems[index].name + randomNum.toString()}');
                              dbHistory!.set({
                                'name': foodItems[index].name,
                                'total': foodItems[index].total,
                                'image': foodItems[index].image,
                                'price': foodItems[index].price *
                                    foodItems[index].total!,
                              });
                              dbRef!
                                  .child(foodItems[index].name +
                                      auth.currentUser!.uid)
                                  .remove();
                              setState(() {
                                foodItems.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Complete Receive the order')));
                            },
                            child: Text('Click to complete the order')))
                  ],
                ),
                leading: Image.network(foodItems[index].image),
              ),
            );
          },
        ),
      ),
    );
  }
}
