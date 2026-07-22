import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/features/providers/data/provider_profile_api.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';

/// Domain state for the authenticated user's provider profile (not auth session).
class ProviderProfileNotifier extends AsyncNotifier<ProviderProfile?> {
  ProviderProfileApi get _api => ref.read(providerProfileApiProvider);

  @override
  Future<ProviderProfile?> build() async {
    try {
      return await _api.getMe();
    } on ApiAppException catch (error) {
      if (error.code == 'NOT_FOUND') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> create(CreateProviderProfileInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.create(input));
  }

  Future<void> updateProfile(UpdateProviderProfileInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.update(input));
  }

  Future<void> deactivate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_api.deactivate);
  }

  Future<void> restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_api.restore);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final providerProfileProvider =
    AsyncNotifierProvider<ProviderProfileNotifier, ProviderProfile?>(
  ProviderProfileNotifier.new,
);
