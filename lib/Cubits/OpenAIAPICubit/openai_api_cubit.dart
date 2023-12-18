import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:saqr_voice_assistant/Cubits/OpenAIAPICubit/openai_api_states.dart';

import '../../Shared/constant.dart';

class OpenAiCubit extends Cubit<OpenAiStates> {
  OpenAiCubit() : super(OpenAIInitialState());

  static OpenAiCubit get(context) => BlocProvider.of(context);

  List<Map<String, String>> messages = [];
  Future<String> isArtPromptApi(String prompt) async {
    emit(OpenAiIsArtPromptLoadingState());
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          "messages": [
            {
              "role": "user",
              "content": "Does this message want to generate an AI picture, image, art or anything similar? $prompt .Simply answer with a yes or no",
            },
          ]
        }),
      );
      if(response.statusCode == 200){
        String content = jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch(content){
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dellEAPI(prompt);
            return res;
          default: 
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      emit(OpenAiIsArtPromptSuccessState());
    } catch (e) {
      emit(OpenAiIsArtPromptErrorState());
      return e.toString();
    }
    return 'An error occurred';
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      emit(OpenAiChatGPTLoadingState());
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          "messages": messages,
        }),
      );

      if(response.statusCode == 200){
        String content = jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        emit(OpenAiChatGPTSuccessState());
        return content;
      }
    } catch (e) {
      emit(OpenAiChatGPTErrorState());
      return e.toString();
    }
    return 'An error occurred';
  }

  Future<String> dellEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      emit(OpenAiDellELoadingState());
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'size': '1024x1024',
        }),
      );

      if(response.statusCode == 200){
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      emit(OpenAiDellESuccessState());
    } catch (e) {
      emit(OpenAiDellEErrorState());
      return e.toString();
    }
    return 'An error occurred';
  }
}
