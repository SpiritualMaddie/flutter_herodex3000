import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_cubit.dart';


// TODO spinner when logging in
class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _formKeySignUp = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().signIn(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: _showSignUpDialog,
                    child: const Text("Signup"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSignUpDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Form(
            key: _formKeySignUp,
            child: SimpleDialog(
              constraints: BoxConstraints(minHeight: 330, minWidth: 330),
              contentPadding: EdgeInsets.all(15),
              title: Text("Sign up here"),
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 80, 2, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Back to login"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeySignUp.currentState!.validate()) {
                            context.read<AuthCubit>().signUp(
                              _emailController.text,
                              _passwordController.text,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              // TODO snackbar saying success or failed
                              SnackBar(
                                content: const Text("Succesfully signed up"),
                                backgroundColor: Colors.lightGreen,
                                action: SnackBarAction(
                                  label: "Ok",
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                          else{
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              // TODO snackbar saying success or failed
                              SnackBar(
                                content: const Text("Failed to sign up"),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: "Ok",
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("Signup"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}