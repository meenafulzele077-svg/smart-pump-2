import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/crop_disease_provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_state.dart';
import 'widgets/disease_card.dart';

class DiseaseLibraryScreen extends ConsumerStatefulWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  ConsumerState<DiseaseLibraryScreen> createState() => _DiseaseLibraryScreenState();
}

class _DiseaseLibraryScreenState extends ConsumerState<DiseaseLibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(cropsProvider);
    final diseasesAsync = ref.watch(filteredDiseasesProvider);
    final selectedCrop = ref.watch(selectedCropFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Disease Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/disease-library/scan'),
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Scan a Leaf'),
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref.read(diseaseSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search disease, crop or symptom…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(diseaseSearchQueryProvider.notifier).state = '';
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: cropsAsync.when(
              data: (crops) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All Crops'),
                      selected: selectedCrop == null,
                      onSelected: (_) => ref.read(selectedCropFilterProvider.notifier).state = null,
                    ),
                  ),
                  for (final crop in crops)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(crop.name),
                        selected: selectedCrop == crop.id,
                        onSelected: (_) =>
                            ref.read(selectedCropFilterProvider.notifier).state = crop.id,
                      ),
                    ),
                ],
              ),
              loading: () => const Center(child: LoadingShimmer(height: 30, width: 220)),
              error: (e, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: diseasesAsync.when(
              data: (diseases) {
                if (diseases.isEmpty) {
                  return const Center(
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches found',
                      message: 'Try a different search term or crop filter.',
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: diseases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    return DiseaseCard(
                      disease: disease,
                      onTap: () => context.push('/disease-library/${disease.id}'),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CardShimmer(height: 76),
                ),
              ),
              error: (e, __) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(filteredDiseasesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
