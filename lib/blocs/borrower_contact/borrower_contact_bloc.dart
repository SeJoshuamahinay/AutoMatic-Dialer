import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/commons/services/api_client.dart';
import 'borrower_contact_event.dart';
import 'borrower_contact_state.dart';

class BorrowerContactBloc
    extends Bloc<BorrowerContactEvent, BorrowerContactState> {
  static const int _defaultCountryId = 168;

  BorrowerContactBloc() : super(const BorrowerContactState()) {
    on<BorrowerContactLoadRequested>(_onLoadRequested);
    on<BorrowerContactCountrySelected>(_onCountrySelected);
    on<BorrowerContactRegionSelected>(_onRegionSelected);
    on<BorrowerContactCitySelected>(_onCitySelected);
    on<BorrowerContactBarangaySelected>(_onBarangaySelected);
    on<BorrowerContactSaveRequested>(_onSaveRequested);
    on<BorrowerContactMessageCleared>(_onMessageCleared);
  }

  String _preferredCountryCode(BorrowerCountryOption c) {
    final phone = (c.phoneCode ?? '').trim();
    final code = (c.countryCode ?? '').trim();
    if (phone.isNotEmpty) return phone;
    if (code.isNotEmpty) return code;
    return '';
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _regionName(Map<String, dynamic> r) =>
      (r['reg_desc'] ?? r['name'] ?? '').toString();

  String _cityName(Map<String, dynamic> c) =>
      (c['citymun_desc'] ?? c['name'] ?? '').toString();

  String _barangayName(Map<String, dynamic> b) =>
      (b['brgy_desc'] ?? b['name'] ?? '').toString();

  Map<String, dynamic>? _findByName(
    List<Map<String, dynamic>> source,
    String Function(Map<String, dynamic>) nameGetter,
    String? target,
  ) {
    if (target == null || target.trim().isEmpty) return null;
    final needle = target.trim().toLowerCase();
    for (final item in source) {
      if (nameGetter(item).trim().toLowerCase() == needle) {
        return item;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractCitiesFromRegion(
    Map<String, dynamic> region,
  ) {
    final provinces = _asMapList(region['provinces']);
    final cities = <Map<String, dynamic>>[];
    for (final province in provinces) {
      cities.addAll(_asMapList(province['cities']));
    }
    return cities;
  }

  Future<void> _onLoadRequested(
    BorrowerContactLoadRequested event,
    Emitter<BorrowerContactState> emit,
  ) async {
    emit(state.copyWith(isLoadingCountries: true, clearMessage: true));

    try {
      final response = await ApiClient.get('/api/lenderly/dialer/countries');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      final countries = data
          .map((e) => BorrowerCountryOption.fromJson(e as Map<String, dynamic>))
          .where((e) => e.id > 0)
          .toList();

      BorrowerCountryOption? selected;
      if (event.borrowerCountryId != null) {
        for (final c in countries) {
          if (c.id == event.borrowerCountryId) {
            selected = c;
            break;
          }
        }
      }

      // Fallback to Philippines when borrower country is missing or unmatched.
      selected ??= countries
          .where((c) => c.id == _defaultCountryId)
          .firstOrNull;

      var next = state.copyWith(
        countries: countries,
        isLoadingCountries: false,
        clearMessage: true,
      );

      if (selected != null) {
        next = _applyCountry(next, selected);

        final prefillRegion = _findByName(
          next.regions,
          _regionName,
          event.prefillRegion,
        );
        if (prefillRegion != null) {
          next = _applyRegion(next, prefillRegion);
        }

        final prefillCity = _findByName(
          next.cities,
          _cityName,
          event.prefillCity,
        );
        if (prefillCity != null) {
          next = _applyCity(next, prefillCity);
        }

        final prefillBarangay = _findByName(
          next.barangays,
          _barangayName,
          event.prefillBarangay,
        );
        if (prefillBarangay != null) {
          next = _applyBarangay(next, prefillBarangay);
        }
      }

      emit(next);
    } on AuthSessionExpiredException {
      emit(state.copyWith(isLoadingCountries: false, clearMessage: true));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingCountries: false,
          message: 'Failed to load countries.',
        ),
      );
    }
  }

  BorrowerContactState _applyCountry(
    BorrowerContactState current,
    BorrowerCountryOption country,
  ) {
    return current.copyWith(
      selectedCountry: country,
      selectedCountryName: country.name,
      preferredCountryCode: _preferredCountryCode(country),
      regions: _asMapList(country.regions),
      cities: const [],
      barangays: const [],
      selectedRegion: '',
      selectedCity: '',
      selectedBarangay: '',
      clearMessage: true,
    );
  }

  void _onCountrySelected(
    BorrowerContactCountrySelected event,
    Emitter<BorrowerContactState> emit,
  ) {
    emit(_applyCountry(state, event.country));
  }

  BorrowerContactState _applyRegion(
    BorrowerContactState current,
    Map<String, dynamic> region,
  ) {
    final cities = _extractCitiesFromRegion(region);
    return current.copyWith(
      selectedRegion: _regionName(region),
      cities: cities,
      barangays: const [],
      selectedCity: '',
      selectedBarangay: '',
      clearMessage: true,
    );
  }

  void _onRegionSelected(
    BorrowerContactRegionSelected event,
    Emitter<BorrowerContactState> emit,
  ) {
    emit(_applyRegion(state, event.region));
  }

  BorrowerContactState _applyCity(
    BorrowerContactState current,
    Map<String, dynamic> city,
  ) {
    return current.copyWith(
      selectedCity: _cityName(city),
      barangays: _asMapList(city['barangays']),
      selectedBarangay: '',
      clearMessage: true,
    );
  }

  void _onCitySelected(
    BorrowerContactCitySelected event,
    Emitter<BorrowerContactState> emit,
  ) {
    emit(_applyCity(state, event.city));
  }

  BorrowerContactState _applyBarangay(
    BorrowerContactState current,
    Map<String, dynamic> barangay,
  ) {
    return current.copyWith(
      selectedBarangay: _barangayName(barangay),
      clearMessage: true,
    );
  }

  void _onBarangaySelected(
    BorrowerContactBarangaySelected event,
    Emitter<BorrowerContactState> emit,
  ) {
    emit(_applyBarangay(state, event.barangay));
  }

  Future<void> _onSaveRequested(
    BorrowerContactSaveRequested event,
    Emitter<BorrowerContactState> emit,
  ) async {
    if (event.payload.isEmpty) {
      emit(state.copyWith(message: 'Enter at least one field to update.'));
      return;
    }

    emit(
      state.copyWith(isSaving: true, saveSuccess: false, clearMessage: true),
    );

    try {
      final endpoint =
          '/api/lenderly/dialer/borrower/${event.borrowerId}/contact-address';
      final response = await ApiClient.put(endpoint, body: event.payload);

      if (response.statusCode == 200) {
        emit(
          state.copyWith(
            isSaving: false,
            saveSuccess: true,
            message: 'Borrower contact/address updated.',
          ),
        );
      } else {
        String msg = 'Update failed (HTTP ${response.statusCode})';
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          msg = err['message']?.toString() ?? msg;
        } catch (_) {}
        emit(state.copyWith(isSaving: false, message: msg, saveSuccess: false));
      }
    } on AuthSessionExpiredException {
      emit(
        state.copyWith(isSaving: false, saveSuccess: false, clearMessage: true),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: false,
          message: 'Error: $e',
        ),
      );
    }
  }

  void _onMessageCleared(
    BorrowerContactMessageCleared event,
    Emitter<BorrowerContactState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, saveSuccess: false));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
