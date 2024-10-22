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

  void ask(String prompt) async {
    if (messages.length > 1) {
      messages.removeAt(0);
    }
    messages.add(Message(Role.user, prompt));
    final request = OpenAiRequest(
      maxTokens: 2048,
      messages: messages,
      numGpuLayers: 256,
      /* this seems to have no adverse effects in environments w/o GPU support, ex. Android and web */
      //modelPath:
      //    "/Users/steven.chang/projects/chat_ai/lib/utils/ai_models/Meta-Llama-3.1-8B-Instruct-Q4_K_M-take2.gguf",
      modelPath: "/Users/steven.chang/projects/chat_ai/lib/utils/ai_models/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
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

      if (done) {
        _latestResult.value = response;
      }
    });
    EasyLoading.dismiss();
  }
}
