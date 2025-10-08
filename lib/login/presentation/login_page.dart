import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';

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
    final isLoading = loginState.isLoading;
    final isOnline = connectivity.asData?.value ?? true;

    ref.listen(loginControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful! Welcome ${user.email}'),
              ),
            );
          }
        },
        error: (err, _) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(err.toString())));
          }
        },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          pageUI(context: context, isLoading: isLoading, isOnline:isOnline),
          isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : SizedBox.shrink()
        ],
      )
    );
  }

  Widget pageUI({required BuildContext context, required bool isLoading, required bool isOnline}) {
    return Center(
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
                image: AssetImage('assets/logo.png'),
                height: 100,
                width: 200,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                        onPressed: () {
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
                    width: MediaQuery.of(context).size.width/2,
                    child: ElevatedButton(
                      onPressed:
                          (!isOnline || isLoading)
                              ? null
                              : () async {
                                await ref
                                    .read(loginControllerProvider.notifier)
                                    .login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
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
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Corner radius
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ), // Height
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              const SizedBox(height: 12),
              const Text('or'),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width/2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Corner radius
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14), // Height
                  ),
                  onPressed:
                      (!isOnline || isLoading)
                          ? null
                          : () async {
                            await ref
                                .read(loginControllerProvider.notifier)
                                .signUp(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
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
                          },
                  child: const Text('Sign up', style: TextStyle(fontSize: 16)))),
              if (!isOnline) const SizedBox(height: 8),
              if (!isOnline)
                const Text(
                  'You are offline. Please check your connection.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      );
  }
  }
