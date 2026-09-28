enum StepType { walk, microbus, metro, ferry }

class TransitStep {
  final String id;
  final StepType type;
  final String title;
  final String instruction;
  final String? lineName;
  final String? vehicleSign;
  final String? boardingStop;
  final String? dropoffStop;
  final String? dropoffAdvice;
  final int fareEGP;
  final int durationMinutes;
  final int? distanceMeters;
  final String? note;

  const TransitStep({
    required this.id,
    required this.type,
    required this.title,
    required this.instruction,
    this.lineName,
    this.vehicleSign,
    this.boardingStop,
    this.dropoffStop,
    this.dropoffAdvice,
    required this.fareEGP,
    required this.durationMinutes,
    this.distanceMeters,
    this.note,
  });
}

class TransitRoute {
  final String id;
  final String cityId; // 'portsaid', 'cairo', 'giza'
  final String cityName;
  final String title;
  final String origin;
  final String destination;
  final List<String> keywords;
  final int totalFareEGP;
  final int totalDurationMinutes;
  final int transferCount;
  final String tag;
  final String driverAdvice;
  final List<TransitStep> steps;

  const TransitRoute({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.title,
    required this.origin,
    required this.destination,
    required this.keywords,
    required this.totalFareEGP,
    required this.totalDurationMinutes,
    required this.transferCount,
    required this.tag,
    required this.driverAdvice,
    required this.steps,
  });
}
