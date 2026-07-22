import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/geography/data/geography_api.dart';
import 'package:frontend/features/geography/data/geography_models.dart';

final atollsProvider = FutureProvider<List<Atoll>>((ref) async {
  return ref.watch(geographyApiProvider).listAtolls();
});

final islandsProvider =
    FutureProvider.family<List<Island>, String?>((ref, atollId) async {
  return ref.watch(geographyApiProvider).listIslands(atollId: atollId);
});
