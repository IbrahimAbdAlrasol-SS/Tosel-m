class Shipment {
  String? code;
  int? type;
  int? status;
  int? ordersCount;
  int? merchantsCount;
  String? id;
  bool? deleted;
  String? creationDate;

  Shipment(
      {this.code,
      this.ordersCount,
      this.merchantsCount,
      this.type,
      this.status,
      this.id,
      this.deleted,
      this.creationDate});

  Shipment.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    ordersCount = json['ordersCount']; 
    merchantsCount = json['merchantsCount'];
   
    type = json['type'];
    status = json['status'];
   
    id = json['id'];
    deleted = json['deleted'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (code != null) {
      data['code'] = code;
    }
    if (type != null) {
      data['type'] = type;
    }
    if (status != null) {
      data['status'] = status;
    }
    if (ordersCount != null) {
      data['ordersCount'] = ordersCount;
    }
    if (merchantsCount != null) {
      data['merchantsCount'] = merchantsCount;
    }
    if (id != null) {
      data['id'] = id;
    }
    if (deleted != null) {
      data['deleted'] = deleted;
    }
    if (creationDate != null) {
      data['creationDate'] = creationDate;
    }
    return data;
  }

  factory Shipment.create(Map<String, dynamic> json) {
    return Shipment(
      code: json['code'],
      type: json['type'], 
      status: json['status'],
      ordersCount: json['ordersCount'],
      merchantsCount: json['merchantsCount'],
      id: json['id'],
      deleted: json['deleted'],
      creationDate: json['creationDate'],
    );
  }
}

class ShipmentOrder {
  String? orderId;

  ShipmentOrder({this.orderId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderId != null) {
      data['orderId'] = orderId;
    }
    return data;
  }

  factory ShipmentOrder.fromJson(Map<String, dynamic> json) {
    return ShipmentOrder(
      orderId: json['orderId'],
    );
  }
}