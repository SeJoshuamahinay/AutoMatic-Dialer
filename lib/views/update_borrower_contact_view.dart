import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/blocs/borrower_contact/borrower_contact_bloc.dart';
import 'package:lenderly_dialer/blocs/borrower_contact/borrower_contact_event.dart';
import 'package:lenderly_dialer/blocs/borrower_contact/borrower_contact_state.dart';

class UpdateBorrowerContactView extends StatefulWidget {
  final int borrowerId;
  final String? borrowerName;
  final String? phone;
  final String? mobile;
  final int? borrowerCountryId;
  final String? countryCode;
  final String? address;
  final String? houseNumber;
  final String? street;
  final String? village;
  final String? city;
  final String? state;
  final String? province;
  final String? region;
  final String? postalCode;

  const UpdateBorrowerContactView({
    super.key,
    required this.borrowerId,
    this.borrowerName,
    this.phone,
    this.mobile,
    this.borrowerCountryId,
    this.countryCode,
    this.address,
    this.houseNumber,
    this.street,
    this.village,
    this.city,
    this.state,
    this.province,
    this.region,
    this.postalCode,
  });

  @override
  State<UpdateBorrowerContactView> createState() =>
      _UpdateBorrowerContactViewState();
}

class _UpdateBorrowerContactViewState extends State<UpdateBorrowerContactView> {
  final _formKey = GlobalKey<FormState>();
  final BorrowerContactBloc _bloc = BorrowerContactBloc();

  late final TextEditingController _phoneCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _houseNumberCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCodeCtrl;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.phone ?? '');
    _mobileCtrl = TextEditingController(text: widget.mobile ?? '');
    _houseNumberCtrl = TextEditingController(text: widget.houseNumber ?? '');
    _streetCtrl = TextEditingController(text: widget.street ?? '');
    _postalCodeCtrl = TextEditingController(text: widget.postalCode ?? '');

    _bloc.add(
      BorrowerContactLoadRequested(
        borrowerCountryId: widget.borrowerCountryId,
        prefillRegion: widget.region,
        prefillCity: widget.city,
        prefillBarangay: widget.village,
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _mobileCtrl.dispose();
    _houseNumberCtrl.dispose();
    _streetCtrl.dispose();
    _postalCodeCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  String? _nonEmpty(TextEditingController ctrl) {
    final v = ctrl.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<Map<String, dynamic>?> _pickHierarchyItem(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> source,
    String Function(Map<String, dynamic>) nameGetter,
  ) async {
    if (source.isEmpty) {
      _showSnack('Select higher level first.', isError: true);
      return null;
    }

    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String q = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = source
                .where(
                  (item) =>
                      nameGetter(item).toLowerCase().contains(q.toLowerCase()),
                )
                .toList();
            return AlertDialog(
              title: Text('Select $title'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search $title by name',
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setDialogState(() => q = v),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return ListTile(
                            title: Text(nameGetter(item)),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return picked;
  }

  Future<void> _pickCountry(BorrowerContactState state) async {
    if (state.countries.isEmpty) {
      _showSnack('Country list is not available yet.', isError: true);
      return;
    }

    final picked = await showDialog<BorrowerCountryOption>(
      context: context,
      builder: (context) {
        String q = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = state.countries
                .where((c) => c.name.toLowerCase().contains(q.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text('Select Country'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search country by name',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setDialogState(() => q = v),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          return ListTile(
                            title: Text(c.name),
                            subtitle: Text(
                              [c.phoneCode, c.countryCode]
                                  .whereType<String>()
                                  .where((e) => e.isNotEmpty)
                                  .join(' • '),
                            ),
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked == null || !mounted) return;
    _bloc.add(BorrowerContactCountrySelected(picked));
  }

  Future<void> _pickRegion(BorrowerContactState state) async {
    final picked = await _pickHierarchyItem(
      context,
      'Region',
      state.regions,
      (r) => (r['reg_desc'] ?? r['name'] ?? '').toString(),
    );
    if (picked == null || !mounted) return;
    _bloc.add(BorrowerContactRegionSelected(picked));
  }

  Future<void> _pickCity(BorrowerContactState state) async {
    final picked = await _pickHierarchyItem(
      context,
      'City',
      state.cities,
      (c) => (c['citymun_desc'] ?? c['name'] ?? '').toString(),
    );
    if (picked == null || !mounted) return;
    _bloc.add(BorrowerContactCitySelected(picked));
  }

  Future<void> _pickBarangay(BorrowerContactState state) async {
    final picked = await _pickHierarchyItem(
      context,
      'Barangay',
      state.barangays,
      (b) => (b['brgy_desc'] ?? b['name'] ?? '').toString(),
    );
    if (picked == null || !mounted) return;
    _bloc.add(BorrowerContactBarangaySelected(picked));
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _save(BorrowerContactState state) {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      if (_nonEmpty(_phoneCtrl) != null) 'phone': _nonEmpty(_phoneCtrl),
      if (_nonEmpty(_mobileCtrl) != null) 'mobile': _nonEmpty(_mobileCtrl),
      if (state.selectedCountry != null)
        'country_id': state.selectedCountry!.id,
      if ((widget.address ?? '').trim().isNotEmpty) 'address': widget.address,
      if (_nonEmpty(_houseNumberCtrl) != null)
        'house_number': _nonEmpty(_houseNumberCtrl),
      if (_nonEmpty(_streetCtrl) != null) 'street': _nonEmpty(_streetCtrl),
      if (state.selectedBarangay.trim().isNotEmpty)
        'village': state.selectedBarangay,
      if (state.selectedCity.trim().isNotEmpty) 'city': state.selectedCity,
      if (state.selectedRegion.trim().isNotEmpty)
        'region': state.selectedRegion,
      if (_nonEmpty(_postalCodeCtrl) != null)
        'postal_code': _nonEmpty(_postalCodeCtrl),
    };

    _bloc.add(
      BorrowerContactSaveRequested(
        borrowerId: widget.borrowerId,
        payload: payload,
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required String value,
    required String hint,
    required VoidCallback? onTap,
    required bool enabled,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F4F9),
          ),
          child: Text(
            value.isEmpty ? hint : value,
            style: TextStyle(
              color: value.isEmpty ? Colors.grey[600] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: const Color(0xFFF1F4F9),
        ),
      ),
    );
  }

  String _fullAddressDisplay() {
    final combined = (widget.address ?? '').trim();
    if (combined.isNotEmpty) return combined;

    final parts =
        [
              widget.houseNumber,
              widget.street,
              widget.village,
              widget.city,
              widget.state,
              widget.province,
              widget.region,
              widget.postalCode,
            ]
            .whereType<String>()
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim());

    final built = parts.join(', ');
    return built.isEmpty ? 'No combined address available' : built;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<BorrowerContactBloc, BorrowerContactState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            _showSnack(state.message!, isError: !state.saveSuccess);
            _bloc.add(const BorrowerContactMessageCleared());
          }

          if (state.saveSuccess) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FB),
            appBar: AppBar(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Contact/Address',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (widget.borrowerName != null)
                    Text(
                      widget.borrowerName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              toolbarHeight: widget.borrowerName != null ? 65 : null,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _textField('Phone', _phoneCtrl, hint: '+639...'),
                  _textField('Mobile', _mobileCtrl, hint: '+639...'),
                  _pickerField(
                    label: 'Country',
                    value: state.selectedCountryName,
                    hint: state.isLoadingCountries
                        ? 'Loading countries...'
                        : 'Tap to select country',
                    onTap: () => _pickCountry(state),
                    enabled: !state.isLoadingCountries,
                    isLoading: state.isLoadingCountries,
                  ),
                  _displayField('Address (Combined)', _fullAddressDisplay()),
                  _textField('House Number', _houseNumberCtrl),
                  _textField('Street', _streetCtrl),
                  _pickerField(
                    label: 'Region',
                    value: state.selectedRegion,
                    hint: state.regions.isNotEmpty
                        ? 'Select region'
                        : 'Select country first',
                    onTap: () => _pickRegion(state),
                    enabled: state.regions.isNotEmpty,
                  ),
                  _pickerField(
                    label: 'City / Municipality',
                    value: state.selectedCity,
                    hint: state.cities.isNotEmpty
                        ? 'Select city/municipality'
                        : 'Select region first',
                    onTap: () => _pickCity(state),
                    enabled: state.cities.isNotEmpty,
                  ),
                  _pickerField(
                    label: 'Barangay',
                    value: state.selectedBarangay,
                    hint: state.barangays.isNotEmpty
                        ? 'Select barangay'
                        : 'Select city first',
                    onTap: () => _pickBarangay(state),
                    enabled: state.barangays.isNotEmpty,
                  ),
                  _textField('Postal Code', _postalCodeCtrl),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: state.isSaving ? null : () => _save(state),
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        state.isSaving ? 'Saving...' : 'Save Contact/Address',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
