import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/features/customers/data/customer_profile_api.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';
import 'package:frontend/features/customers/state/customer_profile_provider.dart';

class _FakeCustomerProfileApi implements CustomerProfileApi {
  _FakeCustomerProfileApi();

  CustomerProfile? profile;

  @override
  Future<CustomerProfile> create(CreateCustomerProfileInput input) async {
    profile = CustomerProfile(
      id: 'cp_1',
      userId: 'u1',
      displayName: input.displayName,
      avatarUrl: input.avatarUrl,
      contactEmail: input.contactEmail,
      contactPhone: input.contactPhone,
      status: 'ACTIVE',
      completion: const ProfileCompletion(status: 'COMPLETE', percent: 100),
    );
    return profile!;
  }

  @override
  Future<CustomerProfile> getMe() async {
    if (profile == null) {
      throw const ApiAppException(
        message: 'Customer profile not found',
        code: 'NOT_FOUND',
      );
    }
    return profile!;
  }

  @override
  Future<CustomerProfile> update(UpdateCustomerProfileInput input) async {
    profile = CustomerProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: input.displayName ?? profile!.displayName,
      avatarUrl: input.avatarUrl ?? profile!.avatarUrl,
      contactEmail: input.contactEmail ?? profile!.contactEmail,
      contactPhone: input.contactPhone ?? profile!.contactPhone,
      status: profile!.status,
      completion: profile!.completion,
    );
    return profile!;
  }

  @override
  Future<CustomerProfile> deactivate() async {
    profile = CustomerProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: profile!.displayName,
      status: 'DEACTIVATED',
      completion: profile!.completion,
    );
    return profile!;
  }

  @override
  Future<CustomerProfile> restore() async {
    profile = CustomerProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: profile!.displayName,
      status: 'ACTIVE',
      completion: profile!.completion,
    );
    return profile!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates customer profile and handles missing', () async {
    final api = _FakeCustomerProfileApi();
    final container = ProviderContainer(
      overrides: [customerProfileApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    expect(await container.read(customerProfileProvider.future), isNull);

    await container
        .read(customerProfileProvider.notifier)
        .create(
          const CreateCustomerProfileInput(
            displayName: 'Jordan',
            contactEmail: 'jordan@example.com',
          ),
        );

    final profile = container.read(customerProfileProvider).value;
    expect(profile?.displayName, 'Jordan');
    expect(profile?.isComplete, isTrue);
  });
}
