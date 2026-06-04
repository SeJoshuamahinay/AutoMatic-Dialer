import 'package:equatable/equatable.dart';
import 'borrower_contact_state.dart';

abstract class BorrowerContactEvent extends Equatable {
  const BorrowerContactEvent();

  @override
  List<Object?> get props => [];
}

class BorrowerContactLoadRequested extends BorrowerContactEvent {
  final int? borrowerCountryId;
  final String? prefillRegion;
  final String? prefillCity;
  final String? prefillBarangay;

  const BorrowerContactLoadRequested({
    this.borrowerCountryId,
    this.prefillRegion,
    this.prefillCity,
    this.prefillBarangay,
  });

  @override
  List<Object?> get props => [
    borrowerCountryId,
    prefillRegion,
    prefillCity,
    prefillBarangay,
  ];
}

class BorrowerContactCountrySelected extends BorrowerContactEvent {
  final BorrowerCountryOption country;

  const BorrowerContactCountrySelected(this.country);

  @override
  List<Object?> get props => [country];
}

class BorrowerContactRegionSelected extends BorrowerContactEvent {
  final Map<String, dynamic> region;

  const BorrowerContactRegionSelected(this.region);

  @override
  List<Object?> get props => [region];
}

class BorrowerContactCitySelected extends BorrowerContactEvent {
  final Map<String, dynamic> city;

  const BorrowerContactCitySelected(this.city);

  @override
  List<Object?> get props => [city];
}

class BorrowerContactBarangaySelected extends BorrowerContactEvent {
  final Map<String, dynamic> barangay;

  const BorrowerContactBarangaySelected(this.barangay);

  @override
  List<Object?> get props => [barangay];
}

class BorrowerContactSaveRequested extends BorrowerContactEvent {
  final int borrowerId;
  final Map<String, dynamic> payload;

  const BorrowerContactSaveRequested({
    required this.borrowerId,
    required this.payload,
  });

  @override
  List<Object?> get props => [borrowerId, payload];
}

class BorrowerContactMessageCleared extends BorrowerContactEvent {
  const BorrowerContactMessageCleared();
}
