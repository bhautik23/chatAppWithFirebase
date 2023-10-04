import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

//  collection user
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");


//  saving the userdata

  Future savingUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullname,
      "email": email,
      "group": [],
      "profilePic": "",
      "uid": uid,
    });
  }

//  getting userdata

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

//get user groups
  getUserGroup() async {
    return userCollection.doc(uid).snapshots();
  }

//  creatting a groups
  Future createGroup(String userName, String id, String groupName, String groupPassword) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "groupPassword": groupPassword, // Add the password field
    });

    // Update members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_${userName}"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = await userCollection.doc(uid);
    return await userDocumentReference.update({
      "group": FieldValue.arrayUnion(["${groupDocumentReference.id}_${groupName}"])
    });
  }


//  getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

//  get group members

  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

//search

  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

//function -> bool

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['group'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

//  toggling the group join/exit
  Future togglenGroupJoin(
      String groupId, String userName, String groupName) async {
//    doc reeference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['group'];

    //if user has our groups --> then remove then or also in other part re join
    if (groups.contains("${groupId}_${groupName}")) {
      await userDocumentReference.update({
        "group": FieldValue.arrayRemove(["${groupId}_${groupName}"])
      });
      await userDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_${userName}"])
      });
    } else {
      await userDocumentReference.update({
        "group": FieldValue.arrayUnion(["${groupId}_${groupName}"])
      });
      await userDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_${userName}"])
      });
    }
  }

//  send message

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['messages'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // delete message

  Future<void> deleteMessage(String groupId, String messageId) async {
    try {
      await groupCollection.doc(groupId).collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

}
