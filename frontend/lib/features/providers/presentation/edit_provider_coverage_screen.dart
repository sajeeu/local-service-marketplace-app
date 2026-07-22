import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/errors/error_feedback.dart';
import 'package:frontend/core/theme/app_tokens.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/async_body.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/primary_async_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/geography/data/geography_models.dart';
import 'package:frontend/features/geography/state/geography_providers.dart';
import 'package:frontend/features/providers/state/provider_coverage_provider.dart';
import 'package:go_router/go_router.dart';

class EditProviderCoverageScreen extends ConsumerStatefulWidget {
  const EditProviderCoverageScreen({super.key});

  @override
  ConsumerState<EditProviderCoverageScreen> createState() =>
      _EditProviderCoverageScreenState();
}

class _EditProviderCoverageScreenState
    extends ConsumerState<EditProviderCoverageScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIslandIds = {};
  String? _atollFilterId;
  bool _initializedFromCoverage = false;
  bool _submitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncFromCoverage() {
    final coverage = ref.read(providerCoverageProvider).value;
    if (coverage == null || _initializedFromCoverage) {
      return;
    }
    _selectedIslandIds
      ..clear()
      ..addAll(coverage.islands.map((island) => island.id));
    _initializedFromCoverage = true;
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    await ref
        .read(providerCoverageProvider.notifier)
        .replaceCoverage(_selectedIslandIds);
    final state = ref.read(providerCoverageProvider);
    setState(() => _submitting = false);
    if (!mounted) {
      return;
    }
    if (state.hasError) {
      ErrorFeedback.showSnackBar(context, state.error!);
      return;
    }
    context.go(AppRoutes.providerProfile);
  }

  Future<void> _selectEntireAtoll(String atollId, List<Island> islands) async {
    final inAtoll = islands.where((island) => island.atollId == atollId);
    setState(() {
      _selectedIslandIds.addAll(inAtoll.map((island) => island.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final coverageAsync = ref.watch(providerCoverageProvider);
    final atollsAsync = ref.watch(atollsProvider);
    final islandsAsync = ref.watch(islandsProvider(_atollFilterId));
    final theme = Theme.of(context);

    ref.listen(providerCoverageProvider, (previous, next) {
      if (!_initializedFromCoverage && next.hasValue && next.value != null) {
        setState(_syncFromCoverage);
      }
    });
    if (!_initializedFromCoverage && coverageAsync.hasValue) {
      _syncFromCoverage();
    }

    return AppScaffold(
      title: 'Service areas',
      actions: [
        IconButton(
          tooltip: 'Back to profile',
          onPressed: () => context.go(AppRoutes.providerProfile),
          icon: const Icon(Icons.close),
        ),
      ],
      body: AsyncBody(
        isLoading: coverageAsync.isLoading && !_initializedFromCoverage,
        error: coverageAsync.hasError && !_initializedFromCoverage
            ? coverageAsync.error
            : null,
        onRetry: () => ref.read(providerCoverageProvider.notifier).refresh(),
        builder: () {
          return AsyncBody(
            isLoading: atollsAsync.isLoading || islandsAsync.isLoading,
            error: atollsAsync.hasError
                ? atollsAsync.error
                : (islandsAsync.hasError ? islandsAsync.error : null),
            onRetry: () {
              ref.invalidate(atollsProvider);
              ref.invalidate(islandsProvider(_atollFilterId));
            },
            builder: () {
              final atolls = atollsAsync.value ?? const <Atoll>[];
              final islands = islandsAsync.value ?? const <Island>[];
              final query = _searchController.text.trim().toLowerCase();
              final filtered = islands.where((island) {
                if (query.isEmpty) {
                  return true;
                }
                return island.name.toLowerCase().contains(query) ||
                    (island.atollName?.toLowerCase().contains(query) ?? false) ||
                    island.slug.toLowerCase().contains(query);
              }).toList();

              final selectedIslands = islands
                  .where((island) => _selectedIslandIds.contains(island.id))
                  .toList();
              // Also keep selected islands not in current filter from coverage
              final coverageIslands =
                  coverageAsync.value?.islands ?? const <Island>[];
              for (final island in coverageIslands) {
                if (_selectedIslandIds.contains(island.id) &&
                    selectedIslands.every((s) => s.id != island.id)) {
                  selectedIslands.add(island);
                }
              }

              return ListView(
                children: [
                  const SectionHeader(
                    title: 'Where do you provide services?',
                    subtitle:
                        'Select islands across the Maldives. You can filter by atoll or select an entire atoll.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_selectedIslandIds.isEmpty)
                    const EmptyState(
                      icon: Icons.place_outlined,
                      title: 'No islands selected',
                      message:
                          'Choose one or more islands where customers can book your services.',
                    )
                  else ...[
                    Text(
                      'Selected (${_selectedIslandIds.length})',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: selectedIslands
                          .map(
                            (island) => InputChip(
                              label: Text(
                                island.atollCode != null
                                    ? '${island.name} (${island.atollCode})'
                                    : island.name,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedIslandIds.remove(island.id);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search islands',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String?>(
                    // ignore: deprecated_member_use
                    value: _atollFilterId,
                    decoration: const InputDecoration(
                      labelText: 'Filter by atoll',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All atolls'),
                      ),
                      ...atolls.map(
                        (atoll) => DropdownMenuItem<String?>(
                          value: atoll.id,
                          child: Text('${atoll.name} (${atoll.code})'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _atollFilterId = value);
                    },
                  ),
                  if (_atollFilterId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            _selectEntireAtoll(_atollFilterId!, islands),
                        icon: const Icon(Icons.select_all),
                        label: const Text('Select entire atoll'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Islands',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text('No islands match your filters.'),
                    )
                  else
                    ...filtered.map((island) {
                      final selected = _selectedIslandIds.contains(island.id);
                      return CheckboxListTile(
                        value: selected,
                        contentPadding: EdgeInsets.zero,
                        title: Text(island.name),
                        subtitle: Text(
                          [
                            if (island.atollName != null) island.atollName!,
                            island.type,
                          ].join(' · '),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIslandIds.add(island.id);
                            } else {
                              _selectedIslandIds.remove(island.id);
                            }
                          });
                        },
                      );
                    }),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryAsyncButton(
                    label: 'Save coverage',
                    busyLabel: 'Saving…',
                    isBusy: _submitting,
                    onPressed: _save,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
