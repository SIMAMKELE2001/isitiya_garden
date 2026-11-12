import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_box.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/presentation/lookup_dropdown.dart';
import '../../buyer/data/buyer_providers.dart';
import '../../location/data/location_repository.dart';
import '../../location/models/location_models.dart';
import '../../location/presentation/place_picker.dart';

/// Lets a buyer change their name, phone, community and buyer type.
class EditBuyerProfilePage extends ConsumerStatefulWidget {
  const EditBuyerProfilePage({super.key, required this.profile, this.details});

  final UserProfile profile;
  final BuyerDetails? details;

  @override
  ConsumerState<EditBuyerProfilePage> createState() =>
      _EditBuyerProfilePageState();
}

class _EditBuyerProfilePageState extends ConsumerState<EditBuyerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _phone = TextEditingController(text: widget.profile.phone);
  PlaceSelection _place = const PlaceSelection();
  late int? _buyerTypeId = widget.details?.buyerTypeId;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
      // A new place is created first, then we have an id to save.
      final communityId = await ref
          .read(locationRepositoryProvider)
          .resolve(_place);
      await ref
          .read(authRepositoryProvider)
          .updateBuyerProfile(
            userId: widget.profile.id,
            fullName: _name.text,
            phone: _phone.text,
            communityId: communityId,
            buyerTypeId: _buyerTypeId!,
          );
      // Reload the profile everywhere it is shown.
      ref.invalidate(placesProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(buyerDetailsProvider);
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
                    label: 'Phone number',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                  PlacePicker(
                    initialCommunityId: widget.profile.communityId,
                    onChanged: (selection) => _place = selection,
                  ),
                  const SizedBox(height: 16),
                  LookupDropdown(
                    label: 'Buyer type',
                    hint: 'What best describes you?',
                    items: ref.watch(buyerTypesProvider),
                    initialValue: _buyerTypeId,
                    onChanged: (v) => _buyerTypeId = v,
                    onRetry: () => ref.invalidate(buyerTypesProvider),
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
