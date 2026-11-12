import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_box.dart';
import '../data/auth_errors.dart';
import '../data/auth_providers.dart';
import '../../location/models/location_models.dart';
import '../../location/presentation/place_picker.dart';
import '../models/user_profile.dart';

/// Step 1: choose Farmer or Buyer. Step 2: the matching form.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _farm = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  UserRole? _role;
  PlaceSelection _place = const PlaceSelection();
  int? _buyerTypeId;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _farm, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final signedIn = await ref
          .read(authRepositoryProvider)
          .register(
            email: _email.text,
            password: _password.text,
            role: _role!,
            fullName: _name.text,
            phone: _phone.text,
            communityId: _place.communityId,
            areaId: _place.areaId,
            placeName: _place.newPlaceName,
            farmName: _role == UserRole.farmer ? _farm.text : null,
            buyerTypeId: _role == UserRole.buyer ? _buyerTypeId : null,
          );
      if (!mounted) return;
      // Close this screen so the home screen behind it becomes visible.
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (!signedIn) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. Check your email to confirm it, then log in.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A drop-down filled from a database lookup table, with its own
  /// loading and error states.
  Widget _lookupDropdown({
    required String label,
    required String hint,
    required AsyncValue<List<LookupItem>> items,
    required ValueChanged<int?> onChanged,
    required VoidCallback onRetry,
  }) {
    return items.when(
      data: (list) => AppDropdownField<int>(
        label: label,
        hint: hint,
        items: [
          for (final i in list)
            DropdownMenuItem<int>(value: i.id, child: Text(i.name)),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please choose an option.' : null,
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => TextButton(
        onPressed: onRetry,
        child: Text('Could not load $label. Tap to try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _role;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == null ? 'Create account' : 'Register as a ${role.name}',
        ),
      ),
      body: SafeArea(child: role == null ? _roleChooser() : _form(role)),
    );
  }

  Widget _roleChooser() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Who are you?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.forest,
          ),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.agriculture,
          title: 'I am a Farmer',
          subtitle: 'List the produce you have available',
          onTap: () => setState(() => _role = UserRole.farmer),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.shopping_basket_outlined,
          title: 'I am a Buyer',
          subtitle: 'Find fresh produce near you',
          onTap: () => setState(() => _role = UserRole.buyer),
        ),
      ],
    );
  }

  Widget _form(UserRole role) {
    final isFarmer = role == UserRole.farmer;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Full name',
                hint: 'e.g. Nomsa Mbatha',
                controller: _name,
                textInputAction: TextInputAction.next,
                validator: Validators.fullName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                hint: 'name@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone number',
                hint: '072 555 0142',
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              PlacePicker(onChanged: (selection) => _place = selection),
              const SizedBox(height: 16),
              if (isFarmer)
                AppTextField(
                  label: 'Farm name',
                  hint: 'e.g. Mbatha Family Garden',
                  controller: _farm,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.notEmpty(v, 'Farm name'),
                )
              else
                _lookupDropdown(
                  label: 'Buyer type',
                  hint: 'What best describes you?',
                  items: ref.watch(buyerTypesProvider),
                  onChanged: (v) => _buyerTypeId = v,
                  onRetry: () => ref.invalidate(buyerTypesProvider),
                ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: 'At least 6 characters',
                controller: _password,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                suffix: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirm password',
                hint: 'Type it again',
                controller: _confirm,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    v == _password.text ? null : 'The passwords do not match.',
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
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Text('Create account'),
        ),
        TextButton(
          onPressed: _busy ? null : () => setState(() => _role = null),
          child: const Text('Change role'),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.forest),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: text.bodyMedium?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
