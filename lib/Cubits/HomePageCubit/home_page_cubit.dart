import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:saqr_voice_assistant/Cubits/HomePageCubit/home_page_states.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../OpenAIAPICubit/openai_api_cubit.dart';

class HomePageCubit extends Cubit<HomePageStates>{
  HomePageCubit(): super(HomePageInitialState());

  static HomePageCubit get(context) => BlocProvider.of(context);

  //Listen Functions
  final speechToText = SpeechToText();
  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    emit(InitSpeechToTextState());
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: (result){
      onSpeechResult(result);
    },);
    emit(StartListeningSpeechState());
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    emit(StopListeningSpeechState());
  }

  String lastWords = '';
  Future<void> onSpeechResult(SpeechRecognitionResult result) async {
    lastWords = result.recognizedWords;
    print(lastWords);
    emit(GetResultFromSpeechState());
  }

  //Speak Functions
  final flutterTts = FlutterTts();
  Future<void> initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    await flutterTts.setSpeechRate(0.5);
    emit(InitTextToSpeechState());
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
    emit(StartSpeakingState());
  }

  //display Functions
  String? generatedContent;
  String? generatedImageUrl;
  void contentOrImage(String speech) async{
    if(speech.contains('https')){
      generatedImageUrl = speech;
      generatedContent = null;
    }else{
      generatedImageUrl = null;
      generatedContent = speech;
      await systemSpeak(speech);
    }
    emit(ContentOrImageState());
  }

  Future<void> floatingButton(context) async{
    if (await speechToText.hasPermission &&
        speechToText.isNotListening) {
      await startListening();
    } else if (speechToText.isListening) {
      String prompt = lastWords;
      final speech = await OpenAiCubit.get(context).isArtPromptApi(prompt);
      print(speech);
      contentOrImage(speech);
      await stopListening();
    } else {
      initSpeechToText();
    }
  }

}