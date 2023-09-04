import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as strp;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_food_app/Page/history_page.dart';
import 'package:new_food_app/Page/in_order.dart';
import 'package:new_food_app/login/auth_page.dart';
import 'package:new_food_app/Page/payfood_page.dart';
import 'package:new_food_app/model/food_model.dart';
import 'account/account_info.dart';
import 'firebase_options.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Sqflite();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  strp.Stripe.publishableKey =
      'pk_test_51Ms0xVKaM8s9P8UG5jmel5AASPrMXltndEJF7qCMX0HVEBdW4xqZNpxg00WqVJkenabEeYPBggkveZloNrm7KlXo00CqoeUCr6';
  strp.Stripe.merchantIdentifier = 'lua';
  strp.Stripe.instance.applySettings;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference? dbRef;
  DatabaseReference? dbCheckout;
  bool dataLoaded = false;
  String defName = 'User';
  List<FoodItem> foodItems = [];
  num totalPrice = 0;
  num totalAmount = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() {
    dbRef = FirebaseDatabase.instance.ref().child('foodList');
    DatabaseReference dbName = FirebaseDatabase.instance
        .ref('users/${auth.currentUser!.uid.toString()}/profile/name');
    dbName.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          defName = data.toString();
        });
      }
    });

    dbRef!.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        foodItems = data.entries.map((entry) {
          final itemData = entry.value as Map<dynamic, dynamic>;
          final name = itemData['name'];
          final price = itemData['price'];
          final image = itemData['image'];
          final rate = itemData['rate'];
          return FoodItem(name: name, price: price, image: image, rate: rate);
        }).toList();
        setState(() {
          dataLoaded = true;
        });
      } else {
        setState(() {
          dataLoaded = true;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => HistoryPage()));
              },
              icon: Icon(Icons.shopping_bag)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => const InOrderPage()));
              },
              icon: Icon(Icons.local_shipping)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => const PayPage()));
              },
              icon: Icon(Icons.shopping_cart))
        ],
        title: Text('Food App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(defName),
              accountEmail: Text(auth.currentUser!.email.toString()),
              decoration: BoxDecoration(color: Colors.purple),
              currentAccountPicture: CircleAvatar(
                  foregroundImage: NetworkImage(auth.currentUser!.photoURL!)),
            ),
            ListTile(
              title: Text('Account'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => const Accounts()));
              },
            ),
            ListTile(
              title: Text('LogOut'),
              leading: Icon(Icons.logout),
              onTap: () {
                var dialog = AlertDialog(
                  title: const Text('Logout?'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Are you sure want to logout?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        googleSignIn.signOut();

                        auth.signOut();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
                showDialog(
                    context: context,
                    builder: ((context) {
                      return dialog;
                    }));
              },
            ),
          ],
        ),
      ),
      body: Visibility(
        visible: dataLoaded,
        replacement: Center(child: CircularProgressIndicator()),
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Our Product'),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns you want
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: foodItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          totalPrice = foodItems[index].price;
                          totalAmount = 1;
                        });
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return SingleChildScrollView(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        foodItems[index].image,
                                        height: 300,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        foodItems[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text('Price: \$$totalPrice'),
                                      Text('Total: $totalAmount'),
                                      Center(
                                        child: SizedBox(
                                          width: 120,
                                          child: Card(
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        totalAmount += 1;
                                                        foodItems[index].total =
                                                            totalAmount;
                                                        totalPrice +=
                                                            foodItems[index]
                                                                .price;
                                                      });
                                                    },
                                                    icon: Icon(Icons.add)),
                                                Text(totalAmount.toString()),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (totalAmount == 1) {
                                                        } else {
                                                          totalAmount--;
                                                          foodItems[index]
                                                                  .total =
                                                              totalAmount;
                                                          totalPrice -=
                                                              foodItems[index]
                                                                  .price;
                                                        }
                                                      });
                                                    },
                                                    icon: Icon(Icons.remove)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: SizedBox(
                                          width: 250,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                foodItems[index].total =
                                                    totalAmount;
                                                dbCheckout = await FirebaseDatabase
                                                    .instance
                                                    .ref(
                                                        'users/${auth.currentUser!.uid}/checkout/${foodItems[index].name}');
                                                await dbCheckout!.set({
                                                  'name': foodItems[index].name,
                                                  'price':
                                                      foodItems[index].price,
                                                  'image':
                                                      foodItems[index].image,
                                                  'total':
                                                      foodItems[index].total
                                                });
                                                debugPrint(
                                                    'Succes Add To checkout Page');
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            PayPage()));
                                              },
                                              child: Text(
                                                  'Checkout For \$$totalPrice')),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                        );
                      },
                      child: Card(
                        child: Container(
                          width: 100,
                          margin: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                // Use Expanded to make the image take available height in the Card
                                child: Image.network(
                                  foodItems[index].image,
                                  fit: BoxFit
                                      .cover, // Set the fit property to BoxFit.cover
                                ),
                              ),
                              Text(
                                foodItems[index].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('\$${foodItems[index].price}'),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  Text(foodItems[index].rate.toString())
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
