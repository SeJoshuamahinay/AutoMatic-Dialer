class RoutingPlanStop {
  final int id;
  final String borrower;
  final String type;
  final String? address;
  final String? dueDate;
  final double? lat;
  final double? lng;

  const RoutingPlanStop({
    required this.id,
    required this.borrower,
    required this.type,
    this.address,
    this.dueDate,
    this.lat,
    this.lng,
  });

  bool get isMappable => lat != null && lng != null;

  factory RoutingPlanStop.fromJson(Map<String, dynamic> json) => RoutingPlanStop(
        id: json['id'] as int,
        borrower: json['borrower'] as String? ?? '',
        type: json['type'] as String? ?? '',
        address: json['address'] as String?,
        dueDate: json['due_date'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class RoutingPlan {
  final String? date;
  final bool optimized;
  final double? distanceKm;
  final String? mapsUrl;
  final String? note;
  final List<RoutingPlanStop> stops;
  final List<RoutingPlanStop> unmapped;

  const RoutingPlan({
    this.date,
    required this.optimized,
    this.distanceKm,
    this.mapsUrl,
    this.note,
    required this.stops,
    required this.unmapped,
  });

  bool get isEmpty => stops.isEmpty && unmapped.isEmpty;

  factory RoutingPlan.fromJson(Map<String, dynamic> json) => RoutingPlan(
        date: json['date'] as String?,
        optimized: json['optimized'] as bool? ?? false,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        mapsUrl: json['maps_url'] as String?,
        note: json['note'] as String?,
        stops: (json['stops'] as List<dynamic>? ?? [])
            .map((s) => RoutingPlanStop.fromJson(s as Map<String, dynamic>))
            .toList(),
        unmapped: (json['unmapped'] as List<dynamic>? ?? [])
            .map((s) => RoutingPlanStop.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class RoutingPlanHistoryEntry {
  final String date;
  final int stopsCount;
  final double? distanceKm;

  const RoutingPlanHistoryEntry({
    required this.date,
    required this.stopsCount,
    this.distanceKm,
  });

  factory RoutingPlanHistoryEntry.fromJson(Map<String, dynamic> json) => RoutingPlanHistoryEntry(
        date: json['date'] as String,
        stopsCount: json['stops_count'] as int? ?? 0,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
      );
}
