import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/consent/consent_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the consent service
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService(Supabase.instance.client);
});

/// Provider for latest consent
final latestConsentProvider = FutureProvider.autoDispose<Consent?>((ref) async {
  final consentService = ref.watch(consentServiceProvider);
  return consentService.latest();
});

/// Provider to check if user has accepted a specific version
final hasAcceptedConsentProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, version) async {
  final consentService = ref.watch(consentServiceProvider);
  return consentService.hasAccepted(version);
});
