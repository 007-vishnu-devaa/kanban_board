import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/core/app_images.dart';
import 'package:kanbanboard/core/app_strings.dart';
import 'package:kanbanboard/core/widgets/toast.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'package:kanbanboard/core/auth_storage.dart';
import '../../kanban_board/home_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ValueNotifier<bool> _obscureTextNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _obscureTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final connectivity = ref.watch(connectivityStatusProvider);
    final isOnline = connectivity.asData?.value ?? true;

    ref.listen(loginControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
          }
        },
        error: (err, _) {
          if (mounted) {
            FlutterToast(toastMsg: err.toString()).toast();
          }
        },
      );
    });

    // Always render the page UI so widgets like buttons remain in the tree
    // (tests depend on that). Show a loader overlay inside the page UI when
    // login is in progress (pageUI will handle the overlay based on isLoading).
    return Scaffold(
      body: pageUI(context: context, isLoading: loginState.isLoading, isOnline: isOnline),
    );
  }

  Widget pageUI({required BuildContext context, required bool isLoading, required bool isOnline}) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Image(
                  image: AssetImage(AppImages.appLogo),
                  height: 100,
                  width: 200,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: emailController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: AppStrings.emailTextFieldText,
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.person_2_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: _obscureTextNotifier,
                  builder: (context, obscureText, child) {
                    return TextField(
                      onChanged: (value) {
                        if (passwordController.text.isEmpty && !obscureText) {
                          _obscureTextNotifier.value = true;
                        }
                      },
                      controller: passwordController,
                      obscureText: obscureText,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: AppStrings.passwordTextFieldText,
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[600],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                            color: !obscureText ? Colors.teal : Colors.grey[600],
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (passwordController.text.isNotEmpty) {
                                    _obscureTextNotifier.value = !obscureText;
                                  }
                                },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ElevatedButton(
                    onPressed: (!isOnline || isLoading)
                        ? null
                        : () async {
                            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                              FlutterToast(toastMsg: AppStrings.textFieldValidationText).toast();
                            } else {
                              await ref.read(loginControllerProvider.notifier).login(emailController.text.trim(), passwordController.text.trim());
                              if (!mounted) return;
                              final state = ref.read(loginControllerProvider);
                              state.whenOrNull(
                                data: (user) {
                                  if (user != null) {
                                    // Persist login state
                                    AuthStorage.setLoggedIn(true);
                                    AuthStorage.saveUser(id: user.uid, email: user.email);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomePage(),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Corner radius
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ), // Height
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                AppStrings.loginButtonText,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : const Text(
                            AppStrings.loginButtonText,
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('or'),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Corner radius
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14), // Height
                    ),
                    onPressed: (!isOnline || isLoading)
                        ? null
                        : () async {
                            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                              FlutterToast(toastMsg: AppStrings.textFieldValidationText).toast();
                            } else {
                              await ref.read(loginControllerProvider.notifier).signUp(emailController.text.trim(), passwordController.text.trim());
                              if (!mounted) return;
                              final state = ref.read(loginControllerProvider);
                              state.whenOrNull(
                                data: (user) {
                                  if (user != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomePage(),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                    child: const Text(AppStrings.signUpButtonText, style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }
