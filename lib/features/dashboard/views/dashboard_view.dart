import 'package:flutter/material.dart';


 class DashboardView extends StatefulWidget {
   static String id = 'dashboard_view';
   const DashboardView({super.key});

   @override
   State<DashboardView> createState() => _DashboardViewState();
 }

 class _DashboardViewState extends State<DashboardView> {
   @override
   Widget build(BuildContext context) {
     return const Scaffold(
       backgroundColor: Color.fromRGBO(255, 255, 255, 1),
     );
   }
 }
