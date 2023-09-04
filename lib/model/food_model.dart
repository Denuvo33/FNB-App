class FoodItem {
  String name;
  int price;
  String image;
  num? rate;
  int? id;
  num? total;
  String? status;
  String? userName;
  String? uid;
  bool? orderBtn;

  FoodItem(
      {required this.name,
      required this.price,
      required this.image,
      this.rate,
      this.total,
      this.userName,
      this.uid,
      this.orderBtn = false,
      this.id,
      this.status});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['title'],
      price: json['price'],
      image: json['image'],
      id: json['id'],
      total: json['total'],
    );
  }
}
