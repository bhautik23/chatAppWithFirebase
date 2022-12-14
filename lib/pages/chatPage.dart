import 'package:chat_app_firebase/Widgets/message_tile.dart';
import 'package:chat_app_firebase/Widgets/widgets.dart';
import 'package:chat_app_firebase/pages/groupInfo.dart';
import 'package:chat_app_firebase/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String admin = "";
  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseServices().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseServices().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.7),
        centerTitle: true,
        title: Text(widget.groupName),
        elevation: 1,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupName: widget.groupName,
                      groupId: widget.groupId,
                      adminName: admin,
                    ));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.shade700,
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.7),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                        onPressed: () {
                          sendMessages();
                        },
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return MessagTile(
                      message: snapshot.data?.docs[index]['message'],
                      sender: snapshot.data?.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data?.docs[index]['sender']);
                },
              )
            : SizedBox();
      },
    );
  }

  sendMessages() {
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> chatMessagMap = {
        "message":messageController.text,
        "sender":widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      DatabaseServices().sendMessage(widget.groupId,chatMessagMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
