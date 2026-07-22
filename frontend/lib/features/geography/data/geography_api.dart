import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/geography/data/geography_models.dart';

final geographyApiProvider = Provider<GeographyApi>((ref) {
  return GeographyApi(ref.watch(apiClientProvider));
});

class GeographyApi {
  GeographyApi(this._client);

  final ApiClient _client;

  Future<List<Atoll>> listAtolls({int limit = 100}) async {
    final envelope = await _client.get<List<Atoll>>(
      '/atolls',
      queryParameters: {'limit': limit, 'status': 'ACTIVE'},
      skipAuth: true,
      parseData: (raw) {
        if (raw is! List) {
          return <Atoll>[];
        }
        return raw
            .whereType<Map<String, dynamic>>()
            .map(Atoll.fromJson)
            .toList();
      },
    );
    return envelope.data ?? [];
  }

  Future<List<Island>> listIslands({
    String? atollId,
    String? search,
    int limit = 100,
  }) async {
    final envelope = await _client.get<List<Island>>(
      '/islands',
      queryParameters: {
        'limit': limit,
        'status': 'ACTIVE',
        if (atollId != null && atollId.isNotEmpty) 'atollId': atollId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      skipAuth: true,
      parseData: (raw) {
        if (raw is! List) {
          return <Island>[];
        }
        return raw
            .whereType<Map<String, dynamic>>()
            .map(Island.fromJson)
            .toList();
      },
    );
    return envelope.data ?? [];
  }

  Future<List<Island>> listIslandsByAtoll(String atollId, {int limit = 100}) {
    return listIslands(atollId: atollId, limit: limit);
  }
}
