import 'package:equatable/equatable.dart';

class BorrowerCountryOption extends Equatable {
  final int id;
  final String name;
  final String? countryCode;
  final String? phoneCode;
  final List<dynamic> regions;

  const BorrowerCountryOption({
    required this.id,
    required this.name,
    this.countryCode,
    this.phoneCode,
    this.regions = const [],
  });

  factory BorrowerCountryOption.fromJson(Map<String, dynamic> json) {
    return BorrowerCountryOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      countryCode: json['country_code']?.toString(),
      phoneCode: json['phone_code']?.toString(),
      regions: (json['regions'] as List<dynamic>?) ?? const [],
    );
  }

  @override
  List<Object?> get props => [id, name, countryCode, phoneCode, regions];
}

class BorrowerContactState extends Equatable {
  final bool isLoadingCountries;
  final bool isSaving;
  final bool saveSuccess;
  final String? message;
  final List<BorrowerCountryOption> countries;
  final BorrowerCountryOption? selectedCountry;
  final List<Map<String, dynamic>> regions;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> barangays;
  final String selectedRegion;
  final String selectedCity;
  final String selectedBarangay;
  final String selectedCountryName;
  final String preferredCountryCode;

  const BorrowerContactState({
    this.isLoadingCountries = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.message,
    this.countries = const [],
    this.selectedCountry,
    this.regions = const [],
    this.cities = const [],
    this.barangays = const [],
    this.selectedRegion = '',
    this.selectedCity = '',
    this.selectedBarangay = '',
    this.selectedCountryName = '',
    this.preferredCountryCode = '',
  });

  BorrowerContactState copyWith({
    bool? isLoadingCountries,
    bool? isSaving,
    bool? saveSuccess,
    String? message,
    bool clearMessage = false,
    List<BorrowerCountryOption>? countries,
    BorrowerCountryOption? selectedCountry,
    bool clearSelectedCountry = false,
    List<Map<String, dynamic>>? regions,
    List<Map<String, dynamic>>? cities,
    List<Map<String, dynamic>>? barangays,
    String? selectedRegion,
    String? selectedCity,
    String? selectedBarangay,
    String? selectedCountryName,
    String? preferredCountryCode,
  }) {
    return BorrowerContactState(
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      message: clearMessage ? null : (message ?? this.message),
      countries: countries ?? this.countries,
      selectedCountry: clearSelectedCountry
          ? null
          : (selectedCountry ?? this.selectedCountry),
      regions: regions ?? this.regions,
      cities: cities ?? this.cities,
      barangays: barangays ?? this.barangays,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedBarangay: selectedBarangay ?? this.selectedBarangay,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      preferredCountryCode: preferredCountryCode ?? this.preferredCountryCode,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingCountries,
    isSaving,
    saveSuccess,
    message,
    countries,
    selectedCountry,
    regions,
    cities,
    barangays,
    selectedRegion,
    selectedCity,
    selectedBarangay,
    selectedCountryName,
    preferredCountryCode,
  ];
}
