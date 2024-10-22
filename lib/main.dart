import 'package:chat_ai/utils/chat_tool.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    ChatTool.instance.latestResult.addListener(
      () {
        _addMsg(ChatTool.instance.latestResult.value, isSender: false);
      },
    );
    super.initState();
  }

  var chatMsg = "Hi";
  List<Widget> contents = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    children: contents,
                  ),
                ),
              )),
              MessageBar(
                onSend: (_) {
                  _addMsg(_);
                  ChatTool.instance.ask(_);
                },
                actions: const [
                  Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Icon(Icons.chat)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addMsg(String msg, {bool isSender = true}) {
    var step = MediaQuery.of(context).size.width /2 / 14;
    var h = ((msg.length / step) + 2) * 14;

    setState(() {
      contents.add(
        isSender
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: BubbleNormal(
                  text: msg,
                  isSender: isSender,
                  color: isSender ? const Color(0xFF1B97F3) : Colors.deepPurple,
                  tail: true,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  onDoubleTap: () async {
                    Clipboard.setData(ClipboardData(text: msg)).then(
                      (value) {
                        Fluttertoast.showToast(
                            msg: "Copy to clipboard",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                    );
                  },
                ),
            )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatBubble(
                  clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
                  backGroundColor: Color(0xffE7E7ED),
                  margin: EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    height: h < 150 ? 150 : h,
                    child: Markdown(
                      selectable: true,
                      data: msg,
                      extensionSet: md.ExtensionSet(
                        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        <md.InlineSyntax>[
                          md.EmojiSyntax(),
                          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                        ],
                      ),
                    ),
                  ),
                ),
            ),
      );
    });
  }
}
