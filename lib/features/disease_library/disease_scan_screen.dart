import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/crop_disease_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import 'widgets/disease_card.dart';

class DiseaseScanScreen extends ConsumerStatefulWidget {
  const DiseaseScanScreen({super.key});

  @override
  ConsumerState<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends ConsumerState<DiseaseScanScreen> {
  File? _pickedFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (xfile == null) return;
    final file = File(xfile.path);
    setState(() => _pickedFile = file);
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await ref.read(diseaseScanControllerProvider.notifier).identify(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanState = ref.watch(diseaseScanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan a Leaf')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            radius: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: _pickedFile == null
                    ? Container(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.center_focus_strong_rounded,
                                size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('Take or choose a clear photo of the affected leaf',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_pickedFile!, fit: BoxFit.cover),
                          if (scanState.isLoading) const _ScanningOverlay(),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (scanState.hasValue && scanState.value != null) ...[
            Text('Likely matches', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final match in scanState.value!)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DiseaseCard(
                  disease: match.disease,
                  confidencePercent: match.confidencePercent,
                  onTap: () => context.push('/disease-library/${match.disease.id}'),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'AI identification is indicative only, not a confirmed diagnosis. When unsure, '
              'consult your local Krishi Vigyan Kendra.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (!scanState.isLoading && _pickedFile == null)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.image_search_rounded,
                title: 'No photo yet',
                message: 'Capture or upload a leaf photo above to identify possible diseases.',
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanningOverlay extends StatefulWidget {
  const _ScanningOverlay();

  @override
  State<_ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<_ScanningOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment(0, -1 + 2 * _controller.value),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0),
                        AppColors.secondary,
                        AppColors.secondary.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text('Analyzing leaf pattern…', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
