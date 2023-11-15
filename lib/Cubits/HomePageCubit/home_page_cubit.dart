import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saqr_voice_assistant/Cubits/HomePageCubit/home_page_states.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePageCubit extends Cubit<HomePageStates>{
  HomePageCubit(): super(HomePageInitialState());

  static HomePageCubit get(context) => BlocProvider.of(context);

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
}