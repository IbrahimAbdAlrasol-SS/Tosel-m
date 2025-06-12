import 'package:flutter/material.dart';

class OrderEnum {
  String? name;
  Color? textColor;
  String? icon;
  Color? iconColor;

  Color? color;
  String? description;
  int? value;

  OrderEnum({
    this.name,
    this.icon,
    this.color,
    this.value,
    this.description,
    this.iconColor,
    this.textColor,
  });
}

var orderStatus = [
  //? index = 0
  OrderEnum(
      name: 'قيد الانتظار',
      color: const Color(0xFFFFE500),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'طلبك في انتظار الموافقة',
      value: 0),
  //? index = 1
  OrderEnum(
      name: 'قائمة الاستلام',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'في قائمة الاستلام',
      value: 1),
  //? index = 2
  OrderEnum(
      name: 'قيد الاستلام',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'يتم استلام طلبك من قبل المندوب',
      value: 2),
  //? index = 3
  OrderEnum(
      name: 'تم الاستلام',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم استلام الطلب من قبل المندوب',
      value: 3),
  //? index = 4
  OrderEnum(
      name: 'لم يتم الاستلام',
      color: const Color(0xFFE96363),
      iconColor: Colors.black,
      textColor: Colors.white,
      icon: 'assets/svg/box.svg',
      description: 'لم يتم استلام الطلب من قبل المندوب',
      value: 4),
  //? index = 5
  OrderEnum(
      name: 'في المستودع',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'وصل الطلب إلى المستودع',
      value: 5),
  //? index = 6
  OrderEnum(
      name: 'قائمة التوصيل',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'طلبك في قائمة التوصيل',
      value: 6),
  //? index = 7
  OrderEnum(
      name: 'قيد التوصيل',
      color: const Color(0xFF80D4FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'يتم توصيل طلبك',
      value: 7),
  // ? index = 8
  OrderEnum(
      name: 'تم التوصيل',
      color: const Color(0xFF8CD98C),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم توصيل الطلب للعميل',
      value: 8),
  //? index = 9
  OrderEnum(
      name: 'توصيل جزئي',
      color: const Color(0xFF8CD98C),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'توصيل جزئي للعميل',
      value: 9),
  //? index = 10
  OrderEnum(
      name: 'مؤجل',
      color: const Color(0xFFFFE500),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم تأجيل الطلب',
      value: 10),
  //? index = 11
  OrderEnum(
      name: 'ملغي',
      color: const Color(0xFFE96363),
      iconColor: Colors.black,
      textColor: Colors.white,
      icon: 'assets/svg/box.svg',
      description: 'تم إلغاء الطلب',
      value: 11),
  //? index = 12
  OrderEnum(
      name: 'مرتجع',
      color: const Color(0xFFAA80FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم إرجاع الطلب للمندوب',
      value: 12),
  //? index = 13
  OrderEnum(
      name: 'مكتمل',
      color: const Color(0xFF8CD98C),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم تسوية الحساب',
      value: 13),

//? 0-        Pending,  - في الانتظار
//? 1-        InPickUpShipment, - استحصال قائمة
//? 2-        InPickUpProgress, - قيد الاستحصال
//? 3-        Received, - تم الاستحصال
//? 4-        NotReceived, - لم يتم الاستحصال
//? 5-        InWarehouse, - في المخزن
//? 6-        InDeliveryShipment, - قائمة التوصيل
//? 7-        InDeliveryProgress, - قيد التوصيل
//? 8-        Delivered, - تم التوصيل
//? 9-       PartiallyDelivered, - توصيل جزئي
//? 10-       Rescheduled, - اعادة جدولة
//? 11-       Cancelled, - ملغي
//? 12-       Refunded, - مرتجع
//? 13-       Completed, - منتهي
];

// ignore: unused_element

class OrderSizeEnum {
  String? name;

  int? value;

  OrderSizeEnum({
    this.name,
    this.value,
  });
}

var orderSizes = [
  OrderSizeEnum(name: 'صغير', value: 0),
  OrderSizeEnum(name: 'متوسط', value: 1),
  OrderSizeEnum(name: 'كبير', value: 2),
];
