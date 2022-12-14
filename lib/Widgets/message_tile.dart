import 'package:flutter/material.dart';

class MessagTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessagTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe})
      : super(key: key);

  @override
  State<MessagTile> createState() => _MessagTileState();
}

class _MessagTileState extends State<MessagTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      child: Container(
        margin: widget.sentByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
            color: widget.sentByMe
                ? Theme.of(context).primaryColor.withOpacity(.7)
                : Colors.grey.shade700,
            borderRadius: widget.sentByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))
                : BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white,letterSpacing: -0.3),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
