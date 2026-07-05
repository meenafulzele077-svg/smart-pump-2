import 'dart:math';
import 'dart:typed_data';

import '../../models/disease_model.dart';
import '../crop_disease_service.dart';

class MockCropDiseaseService implements CropDiseaseService {
  final _random = Random();

  static const _crops = [
    CropModel(id: 'cotton', name: 'Cotton', localNameHi: 'कपास', localNameMr: 'कापूस', season: CropSeason.kharif),
    CropModel(id: 'soybean', name: 'Soybean', localNameHi: 'सोयाबीन', localNameMr: 'सोयाबीन', season: CropSeason.kharif),
    CropModel(id: 'tur', name: 'Tur (Pigeon Pea)', localNameHi: 'अरहर / तूर', localNameMr: 'तूर', season: CropSeason.kharif),
    CropModel(id: 'groundnut', name: 'Groundnut', localNameHi: 'मूंगफली', localNameMr: 'भुईमूग', season: CropSeason.kharif),
    CropModel(id: 'wheat', name: 'Wheat', localNameHi: 'गेहूं', localNameMr: 'गहू', season: CropSeason.rabi),
    CropModel(id: 'gram', name: 'Gram (Chickpea)', localNameHi: 'चना', localNameMr: 'हरभरा', season: CropSeason.rabi),
    CropModel(id: 'mustard', name: 'Mustard', localNameHi: 'सरसों', localNameMr: 'मोहरी', season: CropSeason.rabi),
    CropModel(id: 'orange', name: 'Orange (Orchard)', localNameHi: 'संतरा', localNameMr: 'संत्रा', season: CropSeason.perennial),
  ];

  static const _diseases = [
    DiseaseModel(
      id: 'd_cotton_bollworm',
      cropId: 'cotton',
      name: 'Pink Bollworm',
      localNameHi: 'गुलाबी सुंडी',
      scientificName: 'Pectinophora gossypiella',
      severity: DiseaseSeverity.high,
      symptoms: [
        'Small holes on bolls with rosette-shaped flowers',
        'Larvae found inside bolls feeding on seeds',
        'Premature boll opening & stained lint',
      ],
      causes: ['Moth lays eggs on squares/bolls', 'Warm humid conditions favour outbreaks'],
      treatment: [
        'Spray recommended pyrethroid/spinosad-based insecticide as per label',
        'Remove and destroy infested bolls',
        'Install pheromone traps to monitor moth activity',
      ],
      prevention: [
        'Use pheromone traps early in the season',
        'Avoid late sowing',
        'Practice crop rotation with non-host crops',
      ],
      imageAsset: 'assets/images/diseases/cotton_bollworm.png',
    ),
    DiseaseModel(
      id: 'd_cotton_leaf_curl',
      cropId: 'cotton',
      name: 'Cotton Leaf Curl Virus',
      localNameHi: 'पत्ती मरोड़ रोग',
      scientificName: 'CLCuV (Begomovirus)',
      severity: DiseaseSeverity.high,
      symptoms: ['Upward/downward curling of leaves', 'Thickened veins', 'Stunted plant growth'],
      causes: ['Transmitted by whitefly (Bemisia tabaci)', 'Spreads rapidly in warm weather'],
      treatment: [
        'Control whitefly population with recommended insecticides',
        'Remove and destroy severely infected plants',
      ],
      prevention: [
        'Use virus-resistant/tolerant cotton varieties',
        'Avoid overlapping cropping seasons',
        'Monitor and manage whitefly early',
      ],
      imageAsset: 'assets/images/diseases/cotton_leaf_curl.png',
    ),
    DiseaseModel(
      id: 'd_soybean_rust',
      cropId: 'soybean',
      name: 'Soybean Rust',
      localNameHi: 'सोयाबीन रस्ट',
      scientificName: 'Phakopsora pachyrhizi',
      severity: DiseaseSeverity.moderate,
      symptoms: [
        'Small tan to reddish-brown pustules on leaf undersides',
        'Premature yellowing and leaf drop',
      ],
      causes: ['Fungal spores spread by wind and rain splash', 'High humidity & moderate temperatures'],
      treatment: ['Apply triazole or strobilurin fungicides at first sign', 'Ensure good field drainage'],
      prevention: ['Use resistant varieties where available', 'Avoid dense planting', 'Field sanitation after harvest'],
      imageAsset: 'assets/images/diseases/soybean_rust.png',
    ),
    DiseaseModel(
      id: 'd_soybean_yellow_mosaic',
      cropId: 'soybean',
      name: 'Yellow Mosaic Virus',
      localNameHi: 'पीला मोज़ेक वायरस',
      scientificName: 'MYMV',
      severity: DiseaseSeverity.high,
      symptoms: ['Irregular yellow-green mosaic patches on leaves', 'Reduced pod formation'],
      causes: ['Transmitted by whitefly', 'Continuous cropping without rotation'],
      treatment: ['Rogue out infected plants early', 'Control whitefly vector with approved insecticide'],
      prevention: ['Grow tolerant varieties', 'Timely sowing to avoid peak whitefly activity'],
      imageAsset: 'assets/images/diseases/soybean_ymv.png',
    ),
    DiseaseModel(
      id: 'd_tur_wilt',
      cropId: 'tur',
      name: 'Fusarium Wilt',
      localNameHi: 'उकठा रोग',
      scientificName: 'Fusarium udum',
      severity: DiseaseSeverity.high,
      symptoms: ['Sudden wilting of whole plant', 'Yellowing followed by drying of leaves', 'Blackened vascular tissue'],
      causes: ['Soil-borne fungus, persists for years', 'Continuous tur cultivation on the same field'],
      treatment: ['Uproot and burn affected plants', 'Soil application of Trichoderma-based bio-fungicide'],
      prevention: ['Crop rotation with cereals for 3+ years', 'Use wilt-resistant varieties', 'Seed treatment before sowing'],
      imageAsset: 'assets/images/diseases/tur_wilt.png',
    ),
    DiseaseModel(
      id: 'd_groundnut_leafspot',
      cropId: 'groundnut',
      name: 'Tikka Leaf Spot',
      localNameHi: 'टिक्का रोग',
      scientificName: 'Cercospora spp.',
      severity: DiseaseSeverity.moderate,
      symptoms: ['Circular brown/black spots with yellow halo', 'Premature defoliation'],
      causes: ['Warm humid weather', 'Infected crop debris carried over from previous season'],
      treatment: ['Spray chlorothalonil or mancozeb-based fungicide', 'Remove infected debris'],
      prevention: ['Crop rotation', 'Use certified disease-free seed', 'Timely sowing'],
      imageAsset: 'assets/images/diseases/groundnut_tikka.png',
    ),
    DiseaseModel(
      id: 'd_wheat_rust',
      cropId: 'wheat',
      name: 'Yellow (Stripe) Rust',
      localNameHi: 'पीला रतुआ',
      scientificName: 'Puccinia striiformis',
      severity: DiseaseSeverity.high,
      symptoms: ['Yellow-orange stripes of pustules along leaf veins', 'Leaves dry up prematurely'],
      causes: ['Cool moist weather favours spread', 'Wind-borne spores from neighbouring fields'],
      treatment: ['Spray propiconazole or tebuconazole-based fungicide at first appearance'],
      prevention: ['Grow rust-resistant wheat varieties', 'Timely sowing', 'Avoid excess nitrogen'],
      imageAsset: 'assets/images/diseases/wheat_rust.png',
    ),
    DiseaseModel(
      id: 'd_wheat_powdery_mildew',
      cropId: 'wheat',
      name: 'Powdery Mildew',
      localNameHi: 'चूर्णिल आसिता',
      scientificName: 'Blumeria graminis',
      severity: DiseaseSeverity.moderate,
      symptoms: ['White powdery patches on leaves and stems', 'Reduced grain filling'],
      causes: ['Cool, humid, cloudy weather', 'Dense crop canopy with poor air circulation'],
      treatment: ['Apply sulfur-based or systemic fungicide'],
      prevention: ['Avoid excess irrigation & nitrogen', 'Maintain optimum plant spacing'],
      imageAsset: 'assets/images/diseases/wheat_powdery_mildew.png',
    ),
    DiseaseModel(
      id: 'd_gram_blight',
      cropId: 'gram',
      name: 'Ascochyta Blight',
      localNameHi: 'झुलसा रोग',
      scientificName: 'Ascochyta rabiei',
      severity: DiseaseSeverity.moderate,
      symptoms: ['Dark brown lesions with concentric rings on leaves and pods', 'Girdling of stem causing breakage'],
      causes: ['Cool wet weather', 'Infected seed and crop residue'],
      treatment: ['Spray carbendazim or chlorothalonil-based fungicide'],
      prevention: ['Use certified disease-free seed', 'Seed treatment with fungicide before sowing'],
      imageAsset: 'assets/images/diseases/gram_blight.png',
    ),
    DiseaseModel(
      id: 'd_mustard_aphid',
      cropId: 'mustard',
      name: 'Mustard Aphid',
      localNameHi: 'माहू / एफिड',
      scientificName: 'Lipaphis erysimi',
      severity: DiseaseSeverity.moderate,
      symptoms: ['Clusters of small green-grey insects on shoots and pods', 'Curling and yellowing of leaves', 'Sooty mould on honeydew'],
      causes: ['Cool dry weather in Dec-Feb favours multiplication'],
      treatment: ['Spray neem oil or imidacloprid-based insecticide', 'Encourage natural predators like ladybird beetles'],
      prevention: ['Early sowing to avoid peak aphid period', 'Intercropping with mustard trap crop border'],
      imageAsset: 'assets/images/diseases/mustard_aphid.png',
    ),
    DiseaseModel(
      id: 'd_orange_citrus_canker',
      cropId: 'orange',
      name: 'Citrus Canker',
      localNameHi: 'कैंकर रोग',
      scientificName: 'Xanthomonas citri',
      severity: DiseaseSeverity.high,
      symptoms: ['Raised corky lesions on leaves, stems and fruit', 'Yellow halo around lesions', 'Premature fruit/leaf drop'],
      causes: ['Bacterial infection spread by wind-driven rain', 'Entry through wounds/thorn pricks'],
      treatment: ['Prune and destroy infected twigs', 'Spray copper oxychloride-based bactericide'],
      prevention: ['Windbreaks to reduce splash spread', 'Avoid overhead irrigation', 'Disease-free planting material'],
      imageAsset: 'assets/images/diseases/orange_canker.png',
    ),
    DiseaseModel(
      id: 'd_orange_greening',
      cropId: 'orange',
      name: 'Citrus Greening (HLB)',
      localNameHi: 'हरितिमा रोग',
      scientificName: 'Candidatus Liberibacter spp.',
      severity: DiseaseSeverity.high,
      symptoms: ['Blotchy mottled yellowing of leaves', 'Lopsided, bitter, partially green fruit'],
      causes: ['Spread by Asian citrus psyllid insect vector', 'Infected budwood/planting material'],
      treatment: ['No cure — remove and destroy infected trees to stop spread', 'Control psyllid vector with insecticide'],
      prevention: ['Use certified disease-free nursery plants', 'Regular psyllid monitoring & control'],
      imageAsset: 'assets/images/diseases/orange_greening.png',
    ),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 350));

  @override
  Future<List<CropModel>> getCrops() async {
    await _delay();
    return _crops;
  }

  @override
  Future<List<DiseaseModel>> getAllDiseases() async {
    await _delay();
    return _diseases;
  }

  @override
  Future<List<DiseaseModel>> getDiseasesForCrop(String cropId) async {
    await _delay();
    return _diseases.where((d) => d.cropId == cropId).toList();
  }

  @override
  Future<List<DiseaseModel>> search(String query) async {
    await _delay();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _diseases;
    return _diseases.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.localNameHi.contains(q) ||
          d.scientificName.toLowerCase().contains(q) ||
          _crops.firstWhere((c) => c.id == d.cropId).name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<DiseaseMatch>> identifyFromImage(Uint8List imageBytes) async {
    // MOCK ONLY: a real implementation should send [imageBytes] to a
    // vision-capable classifier (e.g. a Claude API call with an image
    // content block, made from your backend — never embed API keys in the
    // app) and map its output to `DiseaseModel`s. Here we simulate a
    // realistic-looking ranked result so the UI/UX can be fully validated.
    await Future.delayed(const Duration(milliseconds: 1400));
    final shuffled = List<DiseaseModel>.from(_diseases)..shuffle(_random);
    final top = shuffled.take(3).toList();
    double confidence = 72 + _random.nextDouble() * 20;
    return top.map((d) {
      final match = DiseaseMatch(disease: d, confidencePercent: confidence.clamp(40, 97));
      confidence -= 18 + _random.nextDouble() * 10;
      return match;
    }).toList();
  }
}
