import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'model/food_model.dart';

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;
  String uid = '';
  String userName = '';
  String address = '';

  List<FoodItem> foodItems = [];
  DatabaseReference? ref;
  Future<void> makePayment(
      {required String amount, required String currency}) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Prospects',
          customerId: paymentIntentData!['customer'],
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        ));
        displayPaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  Future<void> addFoodToDatabase(int idParam) async {
    ref = FirebaseDatabase.instance
        .ref('inOrder/$uid/${foodItems[idParam].name + uid}');
    await ref!.set({
      'name': foodItems[idParam].name,
      'total': foodItems[idParam].total,
      'price': foodItems[idParam].price,
      'image': foodItems[idParam].image,
      'userName': userName,
      'address': address,
      'uid': uid,
      'status': 'Cook',
    });
    debugPrint('Add ${foodItems[idParam].name} to the database success');
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      Get.snackbar('Payment', 'Payment Successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));
      for (int i = 0; i < foodItems.length; i++) {
        addFoodToDatabase(i);
        DatabaseReference dbFood =
            FirebaseDatabase.instance.ref('users/$uid/checkout');
        dbFood.remove();
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        print("Unforeseen error: ${e}");
      }
    } catch (e) {
      print("exception:$e");
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer key',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}
