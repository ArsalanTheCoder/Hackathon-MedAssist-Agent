import 'package:flutter/material.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/health_profile_setup/health_profile_setup.dart';
import '../presentation/healthcare_facility_locator/healthcare_facility_locator.dart';
import '../presentation/solana_wallet/solana_wallet.dart';
import '../presentation/symptom_assessment/symptom_assessment.dart';
import '../presentation/telemedicine_consultation/telemedicine_consultation.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard';
  static const String healthProfileSetup = '/health-profile-setup';
  static const String healthcareFacilityLocator =
      '/healthcare-facility-locator';
  static const String solanaWallet = '/solana-wallet';
  static const String symptomAssessment = '/symptom-assessment';
  static const String telemedicineConsultation = '/telemedicine-consultation';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Dashboard(),
    dashboard: (context) => const Dashboard(),
    healthProfileSetup: (context) => const HealthProfileSetup(),
    healthcareFacilityLocator: (context) => const HealthcareFacilityLocator(),
    solanaWallet: (context) => const SolanaWallet(),
    symptomAssessment: (context) => const SymptomAssessment(),
    telemedicineConsultation: (context) => const TelemedicineConsultation(),
    // TODO: Add your other routes here
  };
}
