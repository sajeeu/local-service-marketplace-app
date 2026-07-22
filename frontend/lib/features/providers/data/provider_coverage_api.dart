import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/providers/data/provider_coverage_models.dart';

final providerCoverageApiProvider = Provider<ProviderCoverageApi>((ref) {
  return ProviderCoverageApi(ref.watch(apiClientProvider));
});

class ProviderCoverageApi {
  ProviderCoverageApi(this._client);

  final ApiClient _client;

  Future<ProviderCoverage> getMine() async {
    final envelope = await _client.get<ProviderCoverage>(
      '/provider-profiles/me/coverage',
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderCoverage> replace(List<String> islandIds) async {
    final envelope = await _client.put<ProviderCoverage>(
      '/provider-profiles/me/coverage',
      data: {'islandIds': islandIds},
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderCoverage> addIslands(List<String> islandIds) async {
    final envelope = await _client.post<ProviderCoverage>(
      '/provider-profiles/me/coverage/islands',
      data: {'islandIds': islandIds},
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderCoverage> removeIslands(List<String> islandIds) async {
    final envelope = await _client.delete<ProviderCoverage>(
      '/provider-profiles/me/coverage/islands',
      data: {'islandIds': islandIds},
      parseData: _parse,
    );
    return envelope.data!;
  }

  Future<ProviderCoverage> addAtoll(String atollId) async {
    final envelope = await _client.post<ProviderCoverage>(
      '/provider-profiles/me/coverage/atolls/$atollId',
      parseData: _parse,
    );
    return envelope.data!;
  }

  static ProviderCoverage? _parse(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return ProviderCoverage.fromJson(raw);
    }
    return null;
  }
}
