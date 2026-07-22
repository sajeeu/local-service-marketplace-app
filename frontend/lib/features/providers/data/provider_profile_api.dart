import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/providers/data/provider_profile_models.dart';

final providerProfileApiProvider = Provider<ProviderProfileApi>((ref) {
  return ProviderProfileApi(ref.watch(apiClientProvider));
});

class ProviderProfileApi {
  ProviderProfileApi(this._client);

  final ApiClient _client;

  Future<ProviderProfile> create(CreateProviderProfileInput input) async {
    final envelope = await _client.post<ProviderProfile>(
      '/provider-profiles',
      data: input.toJson(),
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderProfile> getMe() async {
    final envelope = await _client.get<ProviderProfile>(
      '/provider-profiles/me',
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderProfile> update(UpdateProviderProfileInput input) async {
    final envelope = await _client.patch<ProviderProfile>(
      '/provider-profiles/me',
      data: input.toJson(),
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderProfile> deactivate() async {
    final envelope = await _client.post<ProviderProfile>(
      '/provider-profiles/me/deactivate',
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderProfile> restore() async {
    final envelope = await _client.post<ProviderProfile>(
      '/provider-profiles/me/restore',
      parseData: _parse,
    );
    return envelope.data!;
  }

  static ProviderProfile? _parse(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return ProviderProfile.fromJson(raw);
    }
    return null;
  }
}
