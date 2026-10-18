import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/form_error_box.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/lookup_dropdown.dart';
import '../../produce/data/produce_repository.dart';
import '../../produce/models/produce.dart';
import '../data/farmer_providers.dart';
import '../data/listing_validators.dart';
import '../models/farmer_models.dart';

/// Opens the Add produce form, or the Edit form when [existing] is given.
void openListingForm(BuildContext context, {FarmerListing? existing}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ListingFormPage(existing: existing),
    ),
  );
}

/// One form for both adding (FR05 to FR13) and editing (FR14) produce.
class ListingFormPage extends ConsumerStatefulWidget {
  const ListingFormPage({super.key, this.existing});

  final FarmerListing? existing;

  @override
  ConsumerState<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends ConsumerState<ListingFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.existing?.name);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late final _quantity = TextEditingController(
    text: widget.existing?.quantityLabel,
  );
  late final _price = TextEditingController(
    text: _priceText(widget.existing?.price),
  );
  late final _note = TextEditingController(text: widget.existing?.locationNote);

  late int? _categoryId = widget.existing?.categoryId;
  late int? _unitId = widget.existing?.unitId;
  late int? _communityId =
      widget.existing?.communityId ??
      ref.read(currentProfileProvider).value?.communityId;
  late final Set<int> _buyerTypeIds = {...?widget.existing?.buyerTypeIds};
  late bool _negotiable = widget.existing?.isPriceNegotiable ?? false;
  late AvailabilityStatus _status =
      widget.existing?.status ?? AvailabilityStatus.available;
  late DateTime _from = widget.existing?.availableFrom ?? DateTime.now();
  late DateTime? _until = widget.existing?.availableUntil;
  late String? _existingImagePath = widget.existing?.imagePath;

  XFile? _newImage;
  bool _busy = false;
  String? _stage;
  String? _error;
  String? _dateError;
  String? _typesError;

  bool get _isEditing => widget.existing != null;

  /// 12.0 shows as "12", 12.5 as "12.5".
  static String? _priceText(double? p) =>
      p == null ? null : (p % 1 == 0 ? p.toInt().toString() : p.toString());

  @override
  void dispose() {
    for (final c in [_name, _description, _quantity, _price, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Photo ----------

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      // maxWidth and imageQuality shrink the photo before upload,
      // which saves data on slow connections.
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (file != null && mounted) setState(() => _newImage = file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the camera or gallery.'),
          ),
        );
      }
    }
  }

  Widget _photoPreview() {
    final placeholder = Container(
      color: const Color(0xFFE3EFD3),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.leaf),
          SizedBox(height: 6),
          Text('No photo yet'),
        ],
      ),
    );

    final existingUrl = ref
        .read(produceRepositoryProvider)
        .imageUrl(_existingImagePath);
    final Widget child;
    if (_newImage != null) {
      child = Image.file(File(_newImage!.path), fit: BoxFit.cover);
    } else if (existingUrl != null) {
      child = Image.network(
        existingUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, c, progress) =>
            progress == null ? c : placeholder,
        errorBuilder: (context, error, stack) => placeholder,
      );
    } else {
      child = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(height: 180, width: double.infinity, child: child),
    );
  }

  // ---------- Dates ----------

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? _from : (_until ?? _from);
    final earliest = DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // firstDate must not be after initialDate, or the picker throws.
      firstDate: initial.isBefore(earliest) ? initial : earliest,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _until = picked;
      }
      _dateError = null;
    });
  }

  // ---------- Saving ----------

  /// Checks the rules a normal text field cannot: dates and buyer types.
  bool _validateExtras() {
    final until = _until;
    String? dateError;
    if (until != null &&
        DateTime(
          until.year,
          until.month,
          until.day,
        ).isBefore(DateTime(_from.year, _from.month, _from.day))) {
      dateError = 'The end date cannot be before the start date.';
    }
    final typesError = _buyerTypeIds.isEmpty
        ? 'Choose at least one buyer type.'
        : null;
    setState(() {
      _dateError = dateError;
      _typesError = typesError;
    });
    return dateError == null && typesError == null;
  }

  Future<void> _submit() async {
    final fieldsOk = _formKey.currentState!.validate();
    final extrasOk = _validateExtras();
    if (!fieldsOk || !extrasOk) return;

    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    final repo = ref.read(farmerRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    String? uploaded;
    try {
      var imagePath = _existingImagePath;
      if (_newImage != null) {
        setState(() => _stage = 'Uploading photo...');
        uploaded = await repo.uploadImage(profile.id, _newImage!);
        imagePath = uploaded;
      }

      setState(() => _stage = 'Saving listing...');
      final priceText = _price.text.trim();
      final description = _description.text.trim();
      final note = _note.text.trim();
      final input = ListingInput(
        name: _name.text,
        categoryId: _categoryId!,
        description: description.isEmpty ? null : description,
        quantity: ListingValidators.parseNumber(_quantity.text)!,
        unitId: _unitId!,
        price: priceText.isEmpty
            ? null
            : ListingValidators.parseNumber(priceText),
        isPriceNegotiable: _negotiable,
        status: _status,
        availableFrom: _from,
        availableUntil: _until,
        communityId: _communityId!,
        locationNote: note.isEmpty ? null : note,
        imagePath: imagePath,
        buyerTypeIds: _buyerTypeIds,
      );

      final old = widget.existing;
      if (old == null) {
        await repo.createListing(profile.id, input);
      } else {
        await repo.updateListing(old, input);
        // The old photo is no longer used if it was replaced or removed.
        if (old.imagePath != null && old.imagePath != imagePath) {
          await repo.removeImageQuietly(old.imagePath!);
        }
      }

      ref.invalidate(myListingsProvider);
      if (!mounted) return;

      if (old == null) {
        navigator.pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ListingSuccessPage()),
        );
      } else {
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Listing updated.')),
        );
      }
    } catch (_) {
      // If the photo went up but saving failed, do not leave it behind.
      if (uploaded != null) await repo.removeImageQuietly(uploaded);
      if (mounted) {
        setState(
          () => _error = 'Something went wrong. Please try again. Your details are still here.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _stage = null;
        });
      }
    }
  }

  // ---------- Screen ----------

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final heading = text.titleSmall?.copyWith(fontWeight: FontWeight.w700);
    final hasPhoto = _newImage != null || _existingImagePath != null;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit produce' : 'Add produce')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Photo', style: heading),
            const SizedBox(height: 6),
            _photoPreview(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _pickImage,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(hasPhoto ? 'Change photo' : 'Add a photo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                if (hasPhoto) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _newImage = null;
                            _existingImagePath = null;
                          }),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Produce name',
                    hint: 'e.g. Spinach',
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    validator: ListingValidators.name,
                  ),
                  const SizedBox(height: 16),
                  LookupDropdown(
                    label: 'Category',
                    hint: 'Choose a category',
                    items: ref.watch(categoryLookupProvider),
                    initialValue: _categoryId,
                    onChanged: (v) => _categoryId = v,
                    onRetry: () => ref.invalidate(categoryLookupProvider),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Description (optional)',
                    hint: 'Fresh, picked this morning...',
                    controller: _description,
                    maxLines: 3,
                    validator: ListingValidators.description,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          label: 'Quantity',
                          hint: 'e.g. 20',
                          controller: _quantity,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: ListingValidators.quantity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: LookupDropdown(
                          label: 'Sold per',
                          hint: 'Unit',
                          items: ref.watch(unitLookupProvider),
                          initialValue: _unitId,
                          onChanged: (v) => _unitId = v,
                          onRetry: () => ref.invalidate(unitLookupProvider),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Price in rand (R)',
                    hint: 'e.g. 12 or 12.50',
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        ListingValidators.price(v, isRequired: !_negotiable),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Price is negotiable',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Buyers can talk to you about the price.',
                    ),
                    value: _negotiable,
                    onChanged: (v) => setState(() => _negotiable = v),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Availability', style: heading),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in AvailabilityStatus.values)
                          ChoicePill(
                            label: s.label,
                            selected: _status == s,
                            onTap: () => setState(() => _status = s),
                          ),
                      ],
                    ),
                  ),
                  if (_status == AvailabilityStatus.unavailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Unavailable produce is hidden from buyers.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Available from',
                          value: Format.date(_from),
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Until (optional)',
                          value: _until == null ? null : Format.date(_until!),
                          onTap: () => _pickDate(isFrom: false),
                          onClear: _until == null
                              ? null
                              : () => setState(() => _until = null),
                        ),
                      ),
                    ],
                  ),
                  if (_dateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _dateError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  LookupDropdown(
                    label: 'Community',
                    hint: 'Where is the produce?',
                    items: ref.watch(communitiesProvider),
                    initialValue: _communityId,
                    onChanged: (v) => _communityId = v,
                    onRetry: () => ref.invalidate(communitiesProvider),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Pickup note (optional)',
                    hint: 'e.g. Next to the church',
                    controller: _note,
                    validator: ListingValidators.locationNote,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Who is this produce for?', style: heading),
                  ),
                  const SizedBox(height: 6),
                  ref
                      .watch(buyerTypesProvider)
                      .when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, _) => TextButton(
                          onPressed: () => ref.invalidate(buyerTypesProvider),
                          child: const Text(
                            'Could not load buyer types. Tap to try again.',
                          ),
                        ),
                        data: (types) => Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in types)
                                ChoicePill(
                                  label: t.name,
                                  selected: _buyerTypeIds.contains(t.id),
                                  onTap: () => setState(() {
                                    _typesError = null;
                                    if (!_buyerTypeIds.remove(t.id)) {
                                      _buyerTypeIds.add(t.id);
                                    }
                                  }),
                                ),
                            ],
                          ),
                        ),
                      ),
                  if (_typesError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _typesError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              FormErrorBox(_error!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(_stage ?? 'Saving...'),
                      ],
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add produce'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable date box that opens the calendar.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: onClear == null
                  ? const Icon(Icons.calendar_today_outlined, size: 20)
                  : IconButton(
                      tooltip: 'Clear date',
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                    ),
            ),
            child: Text(
              value ?? 'Not set',
              style: TextStyle(
                fontSize: 16,
                color: value == null ? AppColors.grey : AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown after a new listing is saved.
class ListingSuccessPage extends ConsumerWidget {
  const ListingSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 96, color: AppColors.leaf),
              const SizedBox(height: 20),
              Text(
                'Produce listed successfully',
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your produce has been listed successfully. Nearby buyers can now see it.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  ref.read(farmerTabProvider.notifier).select(1);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('View my produce'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const ListingFormPage(),
                  ),
                ),
                child: const Text('Add another'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
