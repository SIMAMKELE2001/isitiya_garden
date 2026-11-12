import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_box.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../../farmer/data/farmer_providers.dart';
import '../../farmer/data/listing_validators.dart';
import '../../farmer/models/farmer_models.dart';
import '../../location/data/location_repository.dart';
import '../../location/models/location_models.dart';
import '../../location/presentation/place_picker.dart';

/// Lets a farmer edit the details buyers see (FR04).
class EditFarmerProfilePage extends ConsumerStatefulWidget {
  const EditFarmerProfilePage({super.key, required this.profile, this.details});

  final UserProfile profile;
  final FarmerDetails? details;

  @override
  ConsumerState<EditFarmerProfilePage> createState() =>
      _EditFarmerProfilePageState();
}

class _EditFarmerProfilePageState extends ConsumerState<EditFarmerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _farm = TextEditingController(text: widget.details?.farmName);
  late final _phone = TextEditingController(text: widget.profile.phone);
  late final _whatsapp = TextEditingController(
    text: widget.details?.whatsappNumber,
  );
  late final _about = TextEditingController(text: widget.details?.about);
  PlaceSelection _place = const PlaceSelection();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _farm, _phone, _whatsapp, _about]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final whatsapp = _whatsapp.text.trim();
      final about = _about.text.trim();
      // A new place is created first, then we have an id to save.
      final communityId = await ref
          .read(locationRepositoryProvider)
          .resolve(_place);
      await ref
          .read(farmerRepositoryProvider)
          .updateFarmerProfile(
            userId: widget.profile.id,
            fullName: _name.text,
            phone: _phone.text,
            communityId: communityId,
            farmName: _farm.text,
            // The database refuses empty text here, so send null instead.
            whatsappNumber: whatsapp.isEmpty ? null : whatsapp,
            about: about.isEmpty ? null : about,
          );
      ref.invalidate(placesProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(farmerDetailsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'We could not save your changes. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full name',
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Farm name',
                    controller: _farm,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.notEmpty(v, 'Farm name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone number',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'WhatsApp number (optional)',
                    hint: 'Leave empty to use your phone number',
                    controller: _whatsapp,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? null
                        : Validators.phone(v),
                  ),
                  const SizedBox(height: 16),
                  PlacePicker(
                    initialCommunityId: widget.profile.communityId,
                    onChanged: (selection) => _place = selection,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'About you and your farm (optional)',
                    hint: 'What do you grow? How long have you farmed?',
                    controller: _about,
                    maxLines: 4,
                    validator: ListingValidators.about,
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
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
