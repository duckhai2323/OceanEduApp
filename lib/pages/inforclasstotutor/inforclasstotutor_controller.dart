import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:greenedu/user/parent.dart';

import '../../class/classtotutor.dart';
import '../../routes/names.dart';
import '../../user/user.dart';

class InforClassToTutorController extends GetxController{
  InforClassToTutorController();
  final listClass = <ClassToTutor>[].obs;
  final db = FirebaseFirestore.instance;
  late String? id;
  final classInfor = <ClassToTutor>[].obs;
  final parentInfor = <Parent>[].obs;
  var listener;
  final subscribe = 'Ứng Tuyển'.obs;
  final checkIsEmpty = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    id = Get.arguments;
    DisplayInfor(id.toString());
  }

  Future<void> DisplayInfor(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final classData = await db.collection("classtotutor").withConverter(
        fromFirestore: ClassToTutor.fromFirebase,
        toFirestore: (ClassToTutor classToTutor, options) => classToTutor.toFirebase()
    ).where("classid",isEqualTo: id).get();

    if(classData.docs.isNotEmpty){
      classData.docs.forEach((element) {
        classInfor.add(element.data());
      });
    }
    final ParentData = await db.collection("users").withConverter(
        fromFirestore: Parent.fromFirestore,
        toFirestore: (Parent parent, options) => parent.toFirestore()
    ).where("id",isEqualTo: classInfor[0].userid).get();
    if(ParentData.docs.isNotEmpty){
      ParentData.docs.forEach((element) {
        parentInfor.add(element.data());
      });
    }

    var data =  await db.collection("classtotutor").withConverter(
        fromFirestore: ClassToTutor.fromFirebase,
        toFirestore: (ClassToTutor classToTutor, options) => classToTutor.toFirebase()
    ).where("subject",isEqualTo: classInfor[0].subject).orderBy("timestamp",descending: false);
    listClass.clear();
    listener = data.snapshots().listen((event) {
      for(var change in event.docChanges){
        switch (change.type){
          case DocumentChangeType.added:
            if(change.doc.data()!=null && change.doc.data()!.classid!=id) {
              listClass.insert(0, change.doc.data()!);
            }
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    });
    checkIsEmpty.value = true;
  }

  void Subcribe(){
    if(subscribe.value == 'Ứng Tuyển'){
      subscribe.value = 'Đã Đăng Ký';
    } else {
      subscribe.value = 'Ứng Tuyển';
    }
  }

  Future<void> HandleToInfor(String idStr) async {
    listClass.value.clear();
    classInfor.value.clear();
    parentInfor.value.clear();
    checkIsEmpty.value = false;
    DisplayInfor(idStr);
  }

  void HandleBack(){
    Get.back();
  }
}