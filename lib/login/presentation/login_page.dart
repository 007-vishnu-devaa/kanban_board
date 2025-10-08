import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';

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
  Widget build(BuildContext context) {
    // final loginState = ref.watch(loginControllerProvider);

    // ref.listen(loginControllerProvider, (prev, next) {
    //   next.whenOrNull(
    //     data: (user) {
    //       if (user != null) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Login successful! Welcome ${user.email}')),
    //         );
    //       }
    //     },
    //     error: (err, _) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(err.toString())),
    //       );
    //     },
    //   );
    // });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _obscureTextNotifier,
              builder: (context, obscureText, child) {
                return TextField(
                  controller: passwordController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        _obscureTextNotifier.value = !obscureText;
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // loginState.isLoading
            //     ? const CircularProgressIndicator()
            //     :
            SizedBox(
              width: double.infinity, // Makes button full width of parent
              child: ElevatedButton(
                onPressed: () {
                  // ref.read(loginControllerProvider.notifier)
                  //     .login(emailController.text.trim(), passwordController.text.trim());
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KanbanBoardPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // Corner radius
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14), // Height
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
