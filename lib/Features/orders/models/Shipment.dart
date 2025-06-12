
class Shipment {
  String? code;
  int? type;
  int? status;
  int? ordersCount;
  int? merchantsCount;
  List<String>? ordersId;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['ordersCount'] = this.ordersCount;
    
    data['type'] = this.type;
    data['status'] = this.status;
    data['id'] = this.id;
    data['deleted'] = this.deleted;
    data['creationDate'] = this.creationDate;
    return data;
  }
}

/// Model for creating a new shipment
class CreateShipmentRequest {
  bool? delivered;
  String? delegateId;
  String? merchantId;
  List<OrderRequest>? orders;
  int? priority;

  CreateShipmentRequest({
    this.delivered,
    this.delegateId,
    this.merchantId,
    this.orders,
    this.priority,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (delivered != null) data['delivered'] = delivered;
    if (delegateId != null) data['delegateId'] = delegateId;
    if (merchantId != null) data['merchantId'] = merchantId;
    if (orders != null) {
      data['orders'] = orders!.map((order) => order.toJson()).toList();
    }
    if (priority != null) data['priority'] = priority;
    return data;
  }
}

/// Model for order in shipment request
class OrderRequest {
  String orderId;

  OrderRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {'orderId': orderId};
  }
}

