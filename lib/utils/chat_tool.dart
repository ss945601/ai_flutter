import 'package:file_picker/file_picker.dart';
import 'package:fllama/fllama.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatTool {
  ChatTool._privateConstructor();

  static final ChatTool instance = ChatTool._privateConstructor();
  final ValueNotifier<String> _latestResult = ValueNotifier("");
  ValueNotifier<String> get latestResult => _latestResult;
  final ValueNotifier<String> _realtime = ValueNotifier("");
  ValueNotifier<String> get realtime => _realtime;
  List<Message> messages = [];
  final Map<String, String> modelPath = {};

  Future<void> loadModelFolder() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );
    result?.files.forEach(
      (element) {
        modelPath[element.name] = element.path!;
      },
    );
  }

  void ask(String prompt, String path) async {
    messages.add(Message(Role.user, prompt));
    var request = OpenAiRequest(
      maxTokens: 2048,
      messages: messages,
      numGpuLayers: 256,
      modelPath: path,
      frequencyPenalty: 0.0,
      // Don't use below 1.1, LLMs without a repeat penalty
      // will repeat the same token.
      presencePenalty: 1.1,
      topP: 1.0,
      // Proportional to RAM use.
      // 4096 is a good default.
      // 2048 should be considered on devices with low RAM (<8 GB)
      // 8192 and higher can be considered on device with high RAM (>16 GB)
      // Models are trained on <= a certain context size. Exceeding that # can/will lead to completely incoherent output.
      contextSize: 2048,
      // Don't use 0.0, some models will repeat the same token.
      temperature: 0.1,
      logger: (log) {
        // // ignore: avoid_print
        // print('[llama.cpp] $log');
      },
    );
    EasyLoading.show(status: 'loading...');
    realtime.value = "";
    await fllamaChat(request, (response, done) {
      realtime.value = response;
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      if (done) {
        _latestResult.value = response;
      }
    });
  }
}
