import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/geography/data/geography_models.dart';
import 'package:frontend/features/providers/data/provider_coverage_api.dart';
import 'package:frontend/features/providers/data/provider_coverage_models.dart';
import 'package:frontend/features/providers/state/provider_coverage_provider.dart';

class _FakeCoverageApi implements ProviderCoverageApi {
  ProviderCoverage coverage = const ProviderCoverage(
    providerProfileId: 'pp_1',
    islands: [],
    atollSummaries: [],
  );
  List<String>? lastReplace;

  @override
  Future<ProviderCoverage> getMine() async => coverage;

  @override
  Future<ProviderCoverage> replace(List<String> islandIds) async {
    lastReplace = islandIds;
    coverage = ProviderCoverage(
      providerProfileId: 'pp_1',
      islands: islandIds
          .map(
            (id) => Island(
              id: id,
              atollId: 'atoll_k',
              name: id == 'island_male' ? 'Malé' : id,
              slug: id,
              type: 'INHABITED',
              displayOrder: 1,
              status: 'ACTIVE',
              atollName: 'Kaafu Atoll',
              atollCode: 'K',
            ),
          )
          .toList(),
      atollSummaries: islandIds.isEmpty
          ? const []
          : const [
              CoverageAtollSummary(
                atollId: 'atoll_k',
                atollName: 'Kaafu Atoll',
                atollCode: 'K',
                islandCount: 1,
              ),
            ],
    );
    return coverage;
  }

  @override
  Future<ProviderCoverage> addIslands(List<String> islandIds) async {
    return replace([
      ...coverage.islands.map((i) => i.id),
      ...islandIds,
    ]);
  }

  @override
  Future<ProviderCoverage> removeIslands(List<String> islandIds) async {
    final remaining = coverage.islands
        .where((island) => !islandIds.contains(island.id))
        .map((island) => island.id)
        .toList();
    return replace(remaining);
  }

  @override
  Future<ProviderCoverage> addAtoll(String atollId) async {
    return replace(['island_male', 'island_hulhumale']);
  }
}

void main() {
  test('loads empty coverage', () async {
    final api = _FakeCoverageApi();
    final container = ProviderContainer(
      overrides: [
        providerCoverageApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(providerCoverageProvider.future);
    expect(value?.islands, isEmpty);
  });

  test('replaceCoverage updates selected islands', () async {
    final api = _FakeCoverageApi();
    final container = ProviderContainer(
      overrides: [
        providerCoverageApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    await container.read(providerCoverageProvider.future);
    await container
        .read(providerCoverageProvider.notifier)
        .replaceCoverage({'island_male'});

    final state = container.read(providerCoverageProvider);
    expect(state.hasError, isFalse);
    expect(state.value?.islands.map((i) => i.id), ['island_male']);
    expect(api.lastReplace, ['island_male']);
  });

  test('addAtollCoverage expands to islands', () async {
    final api = _FakeCoverageApi();
    final container = ProviderContainer(
      overrides: [
        providerCoverageApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    await container.read(providerCoverageProvider.future);
    await container
        .read(providerCoverageProvider.notifier)
        .addAtollCoverage('atoll_k');

    final state = container.read(providerCoverageProvider);
    expect(state.value?.islands, hasLength(2));
  });
}
