import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTheme { light, dark }

class ThemeCubit extends Cubit<AppTheme> {
  ThemeCubit() : super(AppTheme.light);

  void themeToggle() {
    debugPrint("Before toggle $state");

    emit(state == AppTheme.light ? AppTheme.dark : AppTheme.light);

    debugPrint("After toggle $state");
  }
}