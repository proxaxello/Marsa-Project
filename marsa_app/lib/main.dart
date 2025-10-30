import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marsa_app/data/providers/ai_tutor_provider.dart';
import 'package:marsa_app/data/providers/auth_provider.dart';
import 'package:marsa_app/data/providers/dictionary_provider.dart';
import 'package:marsa_app/data/providers/folder_provider.dart';
import 'package:marsa_app/data/providers/settings_provider.dart';
import 'package:marsa_app/data/providers/speech_analysis_provider.dart';
import 'package:marsa_app/data/repositories/ai_tutor_repository.dart';
import 'package:marsa_app/data/repositories/auth_repository.dart';
import 'package:marsa_app/data/repositories/dictionary_repository.dart';
import 'package:marsa_app/data/repositories/folder_repository.dart';
import 'package:marsa_app/data/repositories/settings_repository.dart';
import 'package:marsa_app/data/repositories/speech_analysis_repository.dart';
import 'package:marsa_app/logic/blocs/auth/auth_bloc.dart';
import 'package:marsa_app/logic/blocs/auth/auth_event.dart';
import 'package:marsa_app/logic/blocs/auth/auth_state.dart';
import 'package:marsa_app/logic/blocs/chat/chat_bloc.dart';
import 'package:marsa_app/logic/blocs/chat/chat_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_bloc.dart';
import 'package:marsa_app/logic/blocs/search/search_bloc.dart';
import 'package:marsa_app/logic/blocs/settings/settings_bloc.dart';
import 'package:marsa_app/logic/blocs/settings/settings_event.dart';
import 'package:marsa_app/logic/blocs/settings/settings_state.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/presentation/screens/login_screen.dart';
import 'package:marsa_app/presentation/screens/main_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Create the dictionary provider
  final dictionaryProvider = DictionaryProvider();
  
  // Initialize the database
  final db = await dictionaryProvider.initializeDB();
  
  // Ensure the folder_id column exists in the dictionary table
  await dictionaryProvider.ensureFolderIdColumn();
  
  // Ensure new columns exist for enhanced dictionary features
  await dictionaryProvider.ensureNewColumns();
  
  // Create the dictionary repository
  final dictionaryRepository = DictionaryRepository(
    dictionaryProvider: dictionaryProvider,
  );
  
  // Create the folder provider and repository
  final folderProvider = FolderProvider(db);
  final folderRepository = FolderRepository(
    folderProvider: folderProvider,
  );
  
  // Create Dio instance for API calls
  final dio = Dio();
  
  // Create the auth provider and repository
  final authProvider = AuthProvider(dio, prefs);
  final authRepository = AuthRepository(authProvider);
  
  // Create the speech analysis provider and repository
  final speechAnalysisProvider = SpeechAnalysisProvider(dio);
  final speechAnalysisRepository = SpeechAnalysisRepository(
    speechAnalysisProvider: speechAnalysisProvider,
  );
  
  // Create the AI tutor provider and repository
  final aiTutorProvider = AiTutorProvider(dio);
  final aiTutorRepository = AiTutorRepository(
    aiTutorProvider: aiTutorProvider,
  );
  
  // Create the settings provider and repository
  final settingsProvider = SettingsProvider();
  final settingsRepository = SettingsRepository(
    settingsProvider: settingsProvider,
  );
  
  runApp(MarsaApp(
    authRepository: authRepository,
    dictionaryRepository: dictionaryRepository,
    folderRepository: folderRepository,
    speechAnalysisRepository: speechAnalysisRepository,
    aiTutorRepository: aiTutorRepository,
    settingsRepository: settingsRepository,
  ));
}

class MarsaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final DictionaryRepository dictionaryRepository;
  final FolderRepository folderRepository;
  final SpeechAnalysisRepository speechAnalysisRepository;
  final AiTutorRepository aiTutorRepository;
  final SettingsRepository settingsRepository;
  
  const MarsaApp({
    super.key,
    required this.authRepository,
    required this.dictionaryRepository,
    required this.folderRepository,
    required this.speechAnalysisRepository,
    required this.aiTutorRepository,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<DictionaryRepository>(
          create: (context) => dictionaryRepository,
        ),
        RepositoryProvider<FolderRepository>(
          create: (context) => folderRepository,
        ),
        RepositoryProvider<SpeechAnalysisRepository>(
          create: (context) => speechAnalysisRepository,
        ),
        RepositoryProvider<AiTutorRepository>(
          create: (context) => aiTutorRepository,
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => settingsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            )..add(const AppStarted()),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
              dictionaryRepository: dictionaryRepository,
            ),
          ),
          BlocProvider<FolderBloc>(
            create: (context) => FolderBloc(
              folderRepository: folderRepository,
            ),
          ),
          BlocProvider<VoiceLabBloc>(
            create: (context) => VoiceLabBloc(),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              aiTutorRepository: context.read<AiTutorRepository>(),
            )..add(const InitializeChat()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider<WordBloc>(
            create: (context) => WordBloc(
              dictionaryRepository: context.read<DictionaryRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            final isDarkMode = settingsState is SettingsLoaded ? settingsState.isDarkMode : false;
            
            return MaterialApp(
              title: 'Marsa App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  // Show splash screen while checking authentication
                  if (authState is AuthInitial || authState is AuthLoading) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  // Show main screen if authenticated
                  if (authState is AuthAuthenticated) {
                    return const MainScreen();
                  }
                  
                  // Show login screen if not authenticated
                  return const LoginScreen();
                },
              ),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
