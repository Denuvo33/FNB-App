import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_food_app/account/set_address.dart';
import 'package:new_food_app/account/set_name.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  String defName = 'User';
  String address = 'Set Address';
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    DatabaseReference db =
        FirebaseDatabase.instance.ref('users/${auth.currentUser!.uid}/profile');
    db.onValue.listen(((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          address = data['address'] ?? '';
          defName = data['name'] ?? '';
        });
      }
    }));
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Container(
              decoration: const BoxDecoration(color: Colors.amber),
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(defName),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => SetName()));
                            },
                            icon: Icon(Icons.mode_edit_outline_outlined))
                      ],
                    ),
                    Text(auth.currentUser!.email.toString())
                  ],
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          Container(
            child: ListTile(
              title: Text('Regist Address'),
              leading: Icon(Icons.home),
              subtitle: Text(address),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (ctx) => SetAddress()));
              },
            ),
          )
        ],
      ),
    );
  }
}
