import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:mess_firebase/messotd.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key, this.app, this.user}) : super(key: key);
  final FirebaseApp app;
  final String user;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _sendController = TextEditingController();

  final reference = FirebaseDatabase.instance;

  final messName = 'MessTitle';

  List<MessOTD> _list = [];

  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    database.reference().child('Mess').onChildAdded.listen((event) {
      MessOTD messOTD = MessOTD(
          user: event.snapshot.value[messName]['user'],
          text: event.snapshot.value[messName]['text']);
      _list.add(messOTD);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _sendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = reference.reference();
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              title: const Text(
            'DEMO CHAT FIREBASE',
          )),
          body: Column(
            children: [
              Expanded(
                  child: DemoMessageList(
                list: _list,
              )),
              _ActionBar(
                send: () {
                  ref.child('Mess').push().child(messName).set({
                    'text': _sendController.text,
                    'user': widget.user
                  }).asStream();
                  _sendController.clear();
                },
                controller: _sendController,
              ),
            ],
          )),
    );
  }
}

// Phần gửi tin nhắn trong body
class DemoMessageList extends StatelessWidget {
  final List<MessOTD> list;
  const DemoMessageList({Key key, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return MessDesign(
          text: list[index].text,
          user: list[index].user,
        );
      },
    );
  }
}

class MessDesign extends StatelessWidget {
  final String text;
  final String user;
  const MessDesign({Key key, this.text, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(14),
                ),
// Bá gán dùm lại cái size nhá hehe ^^
                height: 70,
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
// Sau khi gõ tin nhắn và gửi thì được phần này
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(user, style: TextStyle(fontSize: 12)),
                      Text(text),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20),
              Icon(Icons.people)
            ],
          ),
        )
      ],
    );
  }
}

/// Phần viết tin nhắn
class _ActionBar extends StatelessWidget {
  final Function send;
  final TextEditingController controller;
  const _ActionBar({Key key, this.send, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(width: 1)),
        child: Row(
// Phần điền thông tin muốn gửi tin nhắn đi
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type something....',
                      border: InputBorder.none,
                    )),
              ),
            ),
// Icon để send tin nhắn
            Padding(
              padding: EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () {
                  send();
                },
                child: Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
