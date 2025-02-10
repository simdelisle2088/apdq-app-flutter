import 'package:apdq_flutter_app/blocs/login/login.state.dart';
import 'package:apdq_flutter_app/blocs/login/login_bloc.dart';
import 'package:apdq_flutter_app/blocs/login/login_event.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/provider/languageProvider.dart';
import 'package:apdq_flutter_app/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ensureEnvironmentInitialized();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureEnvironmentInitialized() async {
    if (dotenv.env.isEmpty) {
      await EnvConfig.initialize();
    }
  }

  void _scrollToFocusedField(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the localizations
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => LoginBloc(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,

          // Add language toggle button in AppBar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () {
                  context.read<LanguageProvider>().toggleLanguage();
                },
                child: Text(
                  l10n.changeLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12BCC1),
                  ),
                ),
              ),
            ],
          ),

          body: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.loginErrorMessage)),
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 30.0,
                    right: 30.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/images/Logorb.png',
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loginTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _usernameController,
                        hintText: l10n.username,
                        prefixIcon: Icons.person_outline,
                        onTap: () => _scrollToFocusedField(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: l10n.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        onTap: () => _scrollToFocusedField(context),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF12BCC1), Color(0xFF5CBA47)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: state is! LoginLoading
                                  ? () {
                                      FocusScope.of(context).unfocus();
                                      context.read<LoginBloc>().add(
                                            LoginSubmitted(
                                              username:
                                                  _usernameController.text,
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state is LoginLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      l10n.login,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
