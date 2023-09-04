import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_food_app/account/set_address.dart';

import '../model/food_model.dart';
import '../payment_controller.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  List<FoodItem> foodItems = [];
  bool dataLoaded = false;
  final paymentController = Get.put(PaymentController());
  num totalAmount = 0;
  var foodName = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference? dbRef;
  DatabaseReference? dbName;
  DatabaseReference? dbFoodDelete;
  DatabaseReference? dbAddress;

  @override
  void initState() {
    super.initState();
    readData();
  }

  readData() {
    dbFoodDelete = FirebaseDatabase.instance
        .ref('users/${auth.currentUser!.uid}/checkout');
    dbRef = FirebaseDatabase.instance
        .ref('users/${auth.currentUser!.uid}/checkout');
    dbRef!.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        foodItems = data.entries.map((entry) {
          final itemData = entry.value as Map<dynamic, dynamic>;
          final name = itemData['name'];
          final price = itemData['price'];
          final image = itemData['image'];
          final total = itemData['total'];

          return FoodItem(name: name, price: price, image: image, total: total);
        }).toList();
        setState(() {
          dataLoaded = true;
        });
      } else {
        setState(() {});
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Visibility(
        visible: dataLoaded,
        replacement: Center(
          child: Text('No Item'),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (BuildContext context, int index) {
                  totalAmount +=
                      foodItems[index].total! * foodItems[index].price;
                  return Card(
                    child: Dismissible(
                      key: Key(foodItems.toString()),
                      onDismissed: (direction) {
                        setState(() {
                          foodName = foodItems[index].name;
                          foodItems.removeAt(index);
                          dbFoodDelete!.child(foodName).remove();
                          debugPrint('You delete $foodName');
                        });
                      },
                      child: ListTile(
                        title: Text(foodItems[index].name),
                        subtitle: Text('${foodItems[index].total}x'),
                        leading: Image.network(foodItems[index].image),
                        trailing: Text(
                            '\$${foodItems[index].price * foodItems[index].total!}'),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  paymentController.uid = auth.currentUser!.uid;
                  paymentController.foodItems = foodItems;
                  dbAddress = await FirebaseDatabase.instance
                      .ref('users/${auth.currentUser!.uid}/profile')
                      .child('address');
                  dbAddress!.onValue.listen((event) {
                    final data = event.snapshot.value;
                    if (data != null) {
                      paymentController.address = data.toString();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Create Your Address First')));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => SetAddress())));
                    }
                  });
                  dbName = await FirebaseDatabase.instance
                      .ref('users/${auth.currentUser!.uid}/profile')
                      .child('name');
                  dbName!.onValue.listen((event) {
                    final data = event.snapshot.value;
                    debugPrint('Your name is $data');
                    paymentController.userName = data.toString();
                  });
                  paymentController.makePayment(
                      amount: '$totalAmount', currency: 'USD');
                },
                child: Text('Pay For All'))
          ],
        ),
      ),
    );
  }
}
