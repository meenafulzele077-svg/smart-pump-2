enum ServiceRecordType {
  routineService,
  motorReplacement,
  repair,
  inspection,
}

class ServiceRecord {
  final String id;
  final ServiceRecordType type;
  final DateTime date;
  final String description;
  final String technicianName;
  final double cost;

  const ServiceRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.description,
    required this.technicianName,
    required this.cost,
  });
}

class WarrantyInfo {
  final String componentName;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String provider;

  const WarrantyInfo({
    required this.componentName,
    required this.purchaseDate,
    required this.expiryDate,
    required this.provider,
  });

  bool get isActive => DateTime.now().isBefore(expiryDate);
  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;
}

class TechnicianContact {
  final String id;
  final String name;
  final String specialization;
  final String phoneNumber;
  final double rating;

  const TechnicianContact({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.rating,
  });
}

class MaintenanceReminder {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;

  const MaintenanceReminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class SparePartRecord {
  final String id;
  final String partName;
  final DateTime replacedOn;
  final double cost;
  final int expectedLifespanMonths;

  const SparePartRecord({
    required this.id,
    required this.partName,
    required this.replacedOn,
    required this.cost,
    required this.expectedLifespanMonths,
  });
}
