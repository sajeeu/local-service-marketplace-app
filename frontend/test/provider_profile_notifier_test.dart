import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/features/providers/data/provider_profile_api.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';
import 'package:frontend/features/providers/state/provider_profile_provider.dart';

class _FakeProviderProfileApi implements ProviderProfileApi {
  _FakeProviderProfileApi({this.profile, this.getMeError});

  ProviderProfile? profile;
  Object? getMeError;
  CreateProviderProfileInput? lastCreate;
  UpdateProviderProfileInput? lastUpdate;

  @override
  Future<ProviderProfile> create(CreateProviderProfileInput input) async {
    lastCreate = input;
    profile = ProviderProfile(
      id: 'pp_1',
      userId: 'u1',
      displayName: input.displayName,
      businessName: input.businessName,
      description: input.description,
      contactEmail: input.contactEmail,
      contactPhone: input.contactPhone,
      websiteUrl: input.websiteUrl,
      logoUrl: input.logoUrl,
      languages: input.languages,
      visibility: input.visibility,
      status: 'ACTIVE',
      completion: const ProfileCompletion(status: 'INCOMPLETE', percent: 25),
    );
    return profile!;
  }

  @override
  Future<ProviderProfile> getMe() async {
    if (getMeError != null) {
      throw getMeError!;
    }
    if (profile == null) {
      throw const ApiAppException(
        message: 'Provider profile not found',
        code: 'NOT_FOUND',
      );
    }
    return profile!;
  }

  @override
  Future<ProviderProfile> update(UpdateProviderProfileInput input) async {
    lastUpdate = input;
    profile = ProviderProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: input.displayName ?? profile!.displayName,
      businessName: input.businessName ?? profile!.businessName,
      description: input.description ?? profile!.description,
      contactEmail: input.contactEmail ?? profile!.contactEmail,
      contactPhone: input.contactPhone ?? profile!.contactPhone,
      websiteUrl: input.websiteUrl ?? profile!.websiteUrl,
      logoUrl: input.logoUrl ?? profile!.logoUrl,
      languages: input.languages ?? profile!.languages,
      visibility: input.visibility ?? profile!.visibility,
      status: profile!.status,
      completion: profile!.completion,
    );
    return profile!;
  }

  @override
  Future<ProviderProfile> deactivate() async {
    profile = ProviderProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: profile!.displayName,
      languages: profile!.languages,
      visibility: profile!.visibility,
      status: 'DEACTIVATED',
      completion: profile!.completion,
    );
    return profile!;
  }

  @override
  Future<ProviderProfile> restore() async {
    profile = ProviderProfile(
      id: profile!.id,
      userId: profile!.userId,
      displayName: profile!.displayName,
      languages: profile!.languages,
      visibility: profile!.visibility,
      status: 'ACTIVE',
      completion: profile!.completion,
    );
    return profile!;
  }
}

class _ThrowingProviderCreateApi extends _FakeProviderProfileApi {
  @override
  Future<ProviderProfile> create(CreateProviderProfileInput input) async {
    throw const ApiAppException(
      message: 'Provider profile already exists',
      code: 'CONFLICT',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('treats NOT_FOUND as missing profile', () async {
    final api = _FakeProviderProfileApi(
      getMeError: const ApiAppException(
        message: 'Provider profile not found',
        code: 'NOT_FOUND',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        providerProfileApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(providerProfileProvider.future);
    expect(value, isNull);
  });

  test('creates and updates provider profile', () async {
    final api = _FakeProviderProfileApi();
    final container = ProviderContainer(
      overrides: [
        providerProfileApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    await container.read(providerProfileProvider.future);
    await container.read(providerProfileProvider.notifier).create(
          const CreateProviderProfileInput(displayName: 'Acme'),
        );

    expect(container.read(providerProfileProvider).value?.displayName, 'Acme');
    expect(api.lastCreate?.displayName, 'Acme');

    await container.read(providerProfileProvider.notifier).updateProfile(
          const UpdateProviderProfileInput(displayName: 'Acme Updated'),
        );
    expect(
      container.read(providerProfileProvider).value?.displayName,
      'Acme Updated',
    );
  });

  test('surfaces API errors on create', () async {
    final throwingApi = _ThrowingProviderCreateApi();
    final failingContainer = ProviderContainer(
      overrides: [
        providerProfileApiProvider.overrideWithValue(throwingApi),
      ],
    );
    addTearDown(failingContainer.dispose);

    await failingContainer.read(providerProfileProvider.future);
    await failingContainer.read(providerProfileProvider.notifier).create(
          const CreateProviderProfileInput(displayName: 'Acme'),
        );
    expect(failingContainer.read(providerProfileProvider).hasError, isTrue);
  });
}
