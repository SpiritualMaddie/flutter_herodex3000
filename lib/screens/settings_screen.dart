import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(),),
      ),
      body: Column(
        children: [
          Center(child: Text("Settings will be here."),),
          OutlinedButton(onPressed: () {
            context.read<AuthCubit>().signOut();
          }, child: Text("Log out")),
          IconButton(onPressed: () {
            context.read<AuthCubit>().signOut();
          }, icon: Icon(Icons.logout, textDirection: .ltr,))
        ],
      ),
    );
  }
}