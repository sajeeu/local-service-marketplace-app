import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/providers/data/provider_coverage_api.dart';
import 'package:frontend/features/providers/data/provider_coverage_models.dart';

final providerCoverageProvider =
    AsyncNotifierProvider<ProviderCoverageNotifier, ProviderCoverage?>(
  ProviderCoverageNotifier.new,
);

class ProviderCoverageNotifier extends AsyncNotifier<ProviderCoverage?> {
  @override
  Future<ProviderCoverage?> build() async {
    try {
      return await ref.read(providerCoverageApiProvider).getMine();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(providerCoverageApiProvider).getMine(),
    );
  }

  Future<void> replaceCoverage(Set<String> islandIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(providerCoverageApiProvider)
          .replace(islandIds.toList()),
    );
  }

  Future<void> addAtollCoverage(String atollId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(providerCoverageApiProvider).addAtoll(atollId),
    );
  }
}
