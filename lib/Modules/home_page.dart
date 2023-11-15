import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saqr_voice_assistant/Cubits/HomePageCubit/home_page_cubit.dart';
import 'package:saqr_voice_assistant/Cubits/HomePageCubit/home_page_states.dart';
import 'package:saqr_voice_assistant/Cubits/OpenAIAPICubit/openai_api_cubit.dart';
import 'package:saqr_voice_assistant/Styles/Colors/pallete.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomePageCubit()..initSpeechToText(),
        ),
        BlocProvider(
          create: (context) => OpenAiCubit(),
        ),
      ],
      child: BlocConsumer<HomePageCubit, HomePageStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = HomePageCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              leading: const Icon(Icons.menu),
              title: const Text('Crow'),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Vietual Assistant Picture
                    Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          margin: const EdgeInsets.only(top: 4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Pallete.assistantCircleColor,
                          ),
                        ),
                        Container(
                          height: 123.0,
                          width: 120.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/crow.png',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Chat bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35.0,
                      ).copyWith(
                        top: 30.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Pallete.borderColor,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Good Morning, what task can I do for you?',
                          style: TextStyle(
                            color: Pallete.mainFontColor,
                            fontSize: 25.0,
                            fontFamily: 'Cera Pro',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        left: 22.0,
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Here are a few features',
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Features list
                    Column(
                      children: [
                        featureBox(
                          Pallete.firstSuggestionBoxColor,
                          'ChatGPT',
                          'A smarter way to stay organized and informed with ChatGPT',
                        ),
                        featureBox(
                          Pallete.secondSuggestionBoxColor,
                          'Dall-E',
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                        ),
                        featureBox(
                          Pallete.thirdSuggestionBoxColor,
                          'Smart Voice Assistant',
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Pallete.firstSuggestionBoxColor,
              child: const Icon(Icons.mic),
              onPressed: () async {
                if (await cubit.speechToText.hasPermission &&
                    cubit.speechToText.isNotListening) {
                  await cubit.startListening();
                } else if (cubit.speechToText.isListening) {
                  String prompt = cubit.lastWords;
                  final speech =
                      await OpenAiCubit.get(context).isArtPromptApi(prompt);
                  print(speech);
                  await cubit.stopListening();
                } else {
                  cubit.initSpeechToText();
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Feature Box
  Widget featureBox(Color color, String headerText, String bodyText) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 35.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.blackColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 3.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                bodyText,
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
