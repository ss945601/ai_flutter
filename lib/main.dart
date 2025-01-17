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
  bool displayRealtimeAI = false;
  String _selectedModel = "";
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  void _showToast(String message) {
    _messangerKey.currentState!
        .showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1),));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.withAlpha(30),
          title: Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 8),
            child: Stack(
              children: [
                IconButton(
                    onPressed: () {
                      ChatTool.instance.loadModelFolder().then(
                        (value) {
                          setState(() {
                            _selectedModel =
                                ChatTool.instance.modelPath.keys.first;
                          });
                        },
                      );
                    },
                    icon: IntrinsicWidth(
                        child: Row(
                      children: [Icon(Icons.computer), Text("Load Models")],
                    ))),
                Center(
                  child: DropdownButton<String>(
                      hint: Text('Select a model'),
                      underline: SizedBox.shrink(),
                      focusColor: Colors.transparent,
                      value: _selectedModel,
                      alignment: Alignment.center,
                      style: TextStyle(
                          fontSize: 16, color: Colors.black.withAlpha(200)),
                      items: ChatTool.instance.modelPath.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedModel = newValue!;
                        });
                        // Optionally, print the path of the selected model
                        if (newValue != null) {
                          print(
                              'Selected Model Path: ${ChatTool.instance.modelPath[_selectedModel]}');
                        }
                      }),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          contents.clear();
                          ChatTool.instance.messages = [];
                        });
                      },
                      icon: const IntrinsicWidth(
                          child: Row(
                        children: [Icon(Icons.change_circle), Text("reset")],
                      ))),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
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
                      if (ChatTool.instance.modelPath.isNotEmpty) {
                        _addMsg(_);
                        ChatTool.instance.ask(
                            _, ChatTool.instance.modelPath[_selectedModel]!);
                      }
                    },
                    actions: const [
                      Padding(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Icon(Icons.chat)),
                    ],
                  )
                ],
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: displayRealtimeAI,
                    child: ValueListenableBuilder(
                      builder: (context, _, __) {
                        return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(20.0),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: Markdown(
                                data: ChatTool.instance.realtime.value));
                      },
                      valueListenable: ChatTool.instance.realtime,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addMsg(String msg, {bool isSender = true}) {
    var step = MediaQuery.of(context).size.width / 2 / 14;
    var h = ((msg.length / step) + 2) * 14;

    setState(() {
      displayRealtimeAI = isSender;
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
                    Clipboard.setData(ClipboardData(text: msg));
                    _showToast("copy to clipboard");
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
                    width: MediaQuery.of(context).size.width / 2,
                    height: h < 150 ? 150 : h,
                    child: GestureDetector(
                      onDoubleTap: () {
                        Clipboard.setData(ClipboardData(
                            text: msg));
                        _showToast("copy to clipboard");
                      },
                      child: Markdown(
                        selectable: true,
                        softLineBreak: true,
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
              ),
      );
    });
  }
}
