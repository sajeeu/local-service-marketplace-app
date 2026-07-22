import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/features/customers/data/customer_profile_api.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';

/// Domain state for the authenticated user's customer profile (not auth session).
class CustomerProfileNotifier extends AsyncNotifier<CustomerProfile?> {
  CustomerProfileApi get _api => ref.read(customerProfileApiProvider);

  @override
  Future<CustomerProfile?> build() async {
    try {
      return await _api.getMe();
    } on ApiAppException catch (error) {
      if (error.code == 'NOT_FOUND') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> create(CreateCustomerProfileInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.create(input));
  }

  Future<void> updateProfile(UpdateCustomerProfileInput input) async {
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

final customerProfileProvider =
    AsyncNotifierProvider<CustomerProfileNotifier, CustomerProfile?>(
  CustomerProfileNotifier.new,
);
