import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/customers/data/customer_profile_models.dart';

final customerProfileApiProvider = Provider<CustomerProfileApi>((ref) {
  return CustomerProfileApi(ref.watch(apiClientProvider));
});

class CustomerProfileApi {
  CustomerProfileApi(this._client);

  final ApiClient _client;

  Future<CustomerProfile> create(CreateCustomerProfileInput input) async {
    final envelope = await _client.post<CustomerProfile>(
      '/customer-profiles',
      data: input.toJson(),
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<CustomerProfile> getMe() async {
    final envelope = await _client.get<CustomerProfile>(
      '/customer-profiles/me',
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<CustomerProfile> update(UpdateCustomerProfileInput input) async {
    final envelope = await _client.patch<CustomerProfile>(
      '/customer-profiles/me',
      data: input.toJson(),
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<CustomerProfile> deactivate() async {
    final envelope = await _client.post<CustomerProfile>(
      '/customer-profiles/me/deactivate',
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<CustomerProfile> restore() async {
    final envelope = await _client.post<CustomerProfile>(
      '/customer-profiles/me/restore',
      parseData: _parse,
    );
    return envelope.data!;
  }

  static CustomerProfile? _parse(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return CustomerProfile.fromJson(raw);
    }
    return null;
  }
}
