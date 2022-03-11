import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mess_firebase/messotd.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key, this.app, this.name, this.phone})
      : super(key: key);
  final FirebaseApp app;
  final String name;
  final String phone;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _sendController = TextEditingController();

  final reference = FirebaseDatabase.instance;

  List<MessOTD> _list = [];
  bool instance = false;
  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    database.reference().child('User').onChildAdded.listen((event) {
      if (event.snapshot.value['phone'] == widget.phone) {
        instance = true;
      }
    });
    database.reference().child('Mess').onChildAdded.listen((event) {
      print(event.snapshot.value['text']);
      if (event.snapshot.value['phone'] == widget.phone ||
          event.snapshot.value['to'] == widget.phone) {
        MessOTD messOTD = MessOTD(
          text: event.snapshot.value['text'],
          phone: event.snapshot.value['phone'],
          to: event.snapshot.value['to'],
          time: event.snapshot.value['time'],
          seen: event.snapshot.value['seen'],
        );
        _list.add(messOTD);
        setState(() {});
      }
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
                  DateTime time = DateTime.now();
                  if (!instance) {
                    ref.child('User').push().set({
                      'name': widget.name,
                      'phone': widget.phone,
                    });
                  }
                  MessOTD messOTD = MessOTD(
                    text: _sendController.text,
                    to: 'talks',
                    phone: widget.phone,
                    time:
                        '${time.hour}:${time.minute}, ${time.day}/${time.month}/${time.year}',
                  );
                  ref.child('Mess').push().set(messOTD.toJson()).asStream();
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
          time: list[index].time,
        );
      },
    );
  }
}

class MessDesign extends StatelessWidget {
  final String text;
  final String time;
  const MessDesign({Key key, this.text, this.time}) : super(key: key);

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
                      Text(time, style: TextStyle(fontSize: 12)),
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
