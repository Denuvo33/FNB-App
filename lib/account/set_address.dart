import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SetAddress extends StatelessWidget {
  const SetAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("users/${auth.currentUser!.uid}/profile");
    final TextEditingController _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Set Address',
                labelText: 'Address',
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await ref.update({'address': _controller.text});
                  debugPrint('Succes Add Data');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Success Add New Address ')));
                  _controller.clear();
                },
                child: Text('Save'))
          ],
        ),
      ),
    );
  }
}
