import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/geography/data/geography_models.dart';
import 'package:frontend/features/geography/state/geography_providers.dart';
import 'package:frontend/features/providers/data/provider_coverage_api.dart';
import 'package:frontend/features/providers/data/provider_coverage_models.dart';
import 'package:frontend/features/providers/presentation/edit_provider_coverage_screen.dart';
import 'package:go_router/go_router.dart';

class _FakeCoverageApi implements ProviderCoverageApi {
  @override
  Future<ProviderCoverage> getMine() async {
    return const ProviderCoverage(
      providerProfileId: 'pp_1',
      islands: [
        Island(
          id: 'island_male',
          atollId: 'atoll_k',
          name: 'Malé',
          slug: 'male',
          type: 'CAPITAL',
          displayOrder: 1,
          status: 'ACTIVE',
          atollName: 'Kaafu Atoll',
          atollCode: 'K',
        ),
      ],
      atollSummaries: [
        CoverageAtollSummary(
          atollId: 'atoll_k',
          atollName: 'Kaafu Atoll',
          atollCode: 'K',
          islandCount: 1,
        ),
      ],
    );
  }

  @override
  Future<ProviderCoverage> replace(List<String> islandIds) async {
    return ProviderCoverage(
      providerProfileId: 'pp_1',
      islands: islandIds
          .map(
            (id) => Island(
              id: id,
              atollId: 'atoll_k',
              name: id == 'island_hulhumale' ? 'Hulhumalé' : 'Malé',
              slug: id,
              type: 'INHABITED',
              displayOrder: 1,
              status: 'ACTIVE',
              atollCode: 'K',
              atollName: 'Kaafu Atoll',
            ),
          )
          .toList(),
      atollSummaries: const [],
    );
  }

  @override
  Future<ProviderCoverage> addIslands(List<String> islandIds) async =>
      replace(islandIds);

  @override
  Future<ProviderCoverage> removeIslands(List<String> islandIds) async =>
      replace(const []);

  @override
  Future<ProviderCoverage> addAtoll(String atollId) async => replace(const []);
}

void main() {
  testWidgets('island selection toggles selected chips', (tester) async {
    final router = GoRouter(
      initialLocation: '/coverage',
      routes: [
        GoRoute(
          path: '/coverage',
          builder: (_, __) => const EditProviderCoverageScreen(),
        ),
        GoRoute(
          path: '/provider-profile',
          builder: (_, __) => const Scaffold(body: Text('profile')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerCoverageApiProvider.overrideWithValue(_FakeCoverageApi()),
          atollsProvider.overrideWith(
            (ref) async => const [
              Atoll(
                id: 'atoll_k',
                name: 'Kaafu Atoll',
                code: 'K',
                displayOrder: 1,
                status: 'ACTIVE',
              ),
            ],
          ),
          islandsProvider.overrideWith(
            (ref, atollId) async => const [
              Island(
                id: 'island_male',
                atollId: 'atoll_k',
                name: 'Malé',
                slug: 'male',
                type: 'CAPITAL',
                displayOrder: 1,
                status: 'ACTIVE',
                atollName: 'Kaafu Atoll',
                atollCode: 'K',
              ),
              Island(
                id: 'island_hulhumale',
                atollId: 'atoll_k',
                name: 'Hulhumalé',
                slug: 'hulhumale',
                type: 'CITY',
                displayOrder: 2,
                status: 'ACTIVE',
                atollName: 'Kaafu Atoll',
                atollCode: 'K',
              ),
            ],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Malé (K)'), findsWidgets);
    expect(find.text('Hulhumalé'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Hulhumalé'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Hulhumalé (K)'), findsOneWidget);
  });
}
