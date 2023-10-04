import 'package:chat_app_firebase/Widgets/widgets.dart';
import 'package:chat_app_firebase/helper/helper_function.dart';
import 'package:chat_app_firebase/pages/chatPage.dart';
import 'package:chat_app_firebase/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSanpshot;
  bool hasUserSearced = false;
  bool isJoined = false;
  String userName = "";
  User? user;
  bool hasGroupPassword = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunction.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.7),
        centerTitle: true,
        title: Text(
          "Search",
          style: TextStyle(fontSize: 23),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(.7),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Groups...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: Icon(
                      Icons.search_sharp,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList(),
        ],
      ),
    );
  }

  Future<String?> showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Group Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Password"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, ""); // Provide a default value
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, passwordController.text ?? ""); // Provide a default value
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseServices()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSanpshot = snapshot;
          _isLoading = false;
          hasUserSearced = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearced
        ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSanpshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
          userName,
          searchSanpshot!.docs[index]['groupId'],
          searchSanpshot!.docs[index]['groupName'],
          searchSanpshot!.docs[index]['admin'],
          searchSanpshot!.docs[index]['groupPassword'],
        );
      },
    )
        : Container();
  }


  joinedOrNot(String userName, String groupId, String groupName, String admin, String groupPassword) async {
    bool isUserJoined = await DatabaseServices(uid: user!.uid).isUserJoined(groupName, groupId, userName);
    bool doesGroupHavePassword = groupPassword.isNotEmpty;

    setState(() {
      isJoined = isUserJoined;
      hasGroupPassword = doesGroupHavePassword;
    });
  }


  Widget groupTile(String userName, String groupId, String groupName, String admin, String groupPassword) {
    joinedOrNot(userName, groupId, groupName, admin, groupPassword);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.7),
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          if (groupPassword.isNotEmpty) {
            // Group has a password, show password dialog
            String? enteredPassword = await showPasswordDialog(context);
            if (enteredPassword!.isNotEmpty && enteredPassword == groupPassword) {
              // Password is correct, join the group
              handleGroupJoin(groupId, userName, groupName);
            } else {
              // Password is incorrect or user cancelled
              showSnackbar(context, Colors.red, "Incorrect password or cancelled");
            }
          } else {
            // Group has no password, directly join
            handleGroupJoin(groupId, userName, groupName);
          }
        },
        child: isJoined
            ? Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            "Joined",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
            : Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor.withOpacity(.7),
          ),
          child: const Text(
            "Join",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void handleGroupJoin(String groupId, String userName, String groupName) async {
    await DatabaseServices(uid: user!.uid).togglenGroupJoin(groupId, userName, groupName);
    setState(() {
      isJoined = !isJoined;
    });
    showSnackbar(
      context,
      Theme.of(context).primaryColor.withOpacity(.9),
      "Successfully joined the group",
    );
    Future.delayed(Duration(seconds: 2), () {
      nextScreen(
        context,
        ChatPage(groupId: groupId, groupName: groupName, userName: userName),
      );
    });
  }
}
