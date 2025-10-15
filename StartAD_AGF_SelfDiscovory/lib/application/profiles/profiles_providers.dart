import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/profiles/profiles_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the profiles service
final Provider<ProfilesService> profilesServiceProvider =
    Provider<ProfilesService>((ref) {
      return ProfilesService(Supabase.instance.client);
    });

/// Provider for current user's profile
final AutoDisposeFutureProvider<UserProfile?> myProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
      final profilesService = ref.watch(profilesServiceProvider);
      return profilesService.getMyProfile();
    });
