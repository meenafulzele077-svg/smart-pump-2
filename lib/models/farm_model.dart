import 'pump_model.dart';
import 'tank_model.dart';

class FarmModel {
  final String id;
  final String name;
  final double areaAcres;
  final List<String> cropTypes;
  final List<PumpModel> pumps;
  final List<TankModel> tanks;

  const FarmModel({
    required this.id,
    required this.name,
    required this.areaAcres,
    required this.cropTypes,
    required this.pumps,
    required this.tanks,
  });
}
