import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quadrojonaskanban/presentation/controllers/chassi_controller.dart';
import 'core/theme.dart';
import 'presentation/pages/meses_chassis_board.dart';

void main() {
  Get.put(ChassiController());
  runApp(const ChassiPlannerApp());
}

class ChassiPlannerApp extends StatelessWidget {
  const ChassiPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chassi Planner',
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme,
      home: const MesesChassisBoard(),
    );
  }
}
