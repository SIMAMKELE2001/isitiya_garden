import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/location_repository.dart';
import '../models/location_models.dart';

/// Province, then district or metro, then town or village. If the
/// village is not in the list, the person types it and it is added.
///
/// Put it inside a Form: every drop-down validates itself. The parent
/// receives the choice through [onChanged].
class PlacePicker extends ConsumerStatefulWidget {
  const PlacePicker({
    super.key,
    required this.onChanged,
    this.initialCommunityId,
  });

  final ValueChanged<PlaceSelection> onChanged;

  /// When editing, the place to show already selected.
  final int? initialCommunityId;

  @override
  ConsumerState<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends ConsumerState<PlacePicker> {
  /// A made-up id for the "My place is not listed" menu item.
  static const _notListed = -1;

  final _newName = TextEditingController();
  int? _provinceId;
  int? _areaId;
  int? _placeId;
  bool _loadingInitial = false;

  @override
  void initState() {
    super.initState();
    _newName.addListener(_emit);
    if (widget.initialCommunityId != null) {
      _loadingInitial = true;
      _loadInitial();
    }
  }

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      final details = await ref
          .read(locationRepositoryProvider)
          .placeDetails(widget.initialCommunityId!);
      if (!mounted) return;
      setState(() {
        if (details != null) {
          _provinceId = details.provinceId;
          _areaId = details.areaId;
          _placeId = details.communityId;
        }
        _loadingInitial = false;
      });
      _emit();
    } catch (_) {
      if (mounted) setState(() => _loadingInitial = false);
    }
  }

  void _emit() {
    final adding = _placeId == _notListed;
    widget.onChanged(
      PlaceSelection(
        communityId: (_placeId != null && !adding) ? _placeId : null,
        areaId: _areaId,
        newPlaceName: adding ? _newName.text.trim() : null,
      ),
    );
  }

  void _selectProvince(int? value) {
    setState(() {
      _provinceId = value;
      _areaId = null;
      _placeId = null;
    });
    _emit();
  }

  Future<void> _selectArea(int? value) async {
    setState(() {
      _areaId = value;
      _placeId = null;
    });
    _emit();
    if (value == null) return;

    // A district nobody has used yet has no places: go straight to typing.
    try {
      final list = await ref.read(placesProvider(value).future);
      if (mounted && _areaId == value && list.isEmpty) {
        setState(() => _placeId = _notListed);
        _emit();
      }
    } catch (_) {}
  }

  void _selectPlace(int? value) {
    setState(() => _placeId = value);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    final adding = _placeId == _notListed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ref
            .watch(provincesProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => _RetryButton(
                what: 'provinces',
                onRetry: () => ref.invalidate(provincesProvider),
              ),
              data: (list) => AppDropdownField<int>(
                key: ValueKey('province-$_provinceId'),
                label: 'Province',
                hint: 'Choose a province',
                initialValue: _provinceId,
                items: [
                  for (final p in list)
                    DropdownMenuItem<int>(value: p.id, child: Text(p.name)),
                ],
                onChanged: _selectProvince,
                validator: (v) => v == null ? 'Choose a province.' : null,
              ),
            ),
        if (_provinceId != null) ...[
          const SizedBox(height: 16),
          ref
              .watch(areasProvider(_provinceId))
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => _RetryButton(
                  what: 'districts',
                  onRetry: () => ref.invalidate(areasProvider),
                ),
                data: (list) => AppDropdownField<int>(
                  key: ValueKey('area-$_provinceId-$_areaId'),
                  label: 'District or metro',
                  hint: 'Choose a district or metro',
                  initialValue: _areaId,
                  items: [
                    for (final a in list)
                      DropdownMenuItem<int>(
                        value: a.id,
                        child: Text(a.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: _selectArea,
                  validator: (v) =>
                      v == null ? 'Choose a district or metro.' : null,
                ),
              ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Not sure? This is the larger area your town or village belongs to.',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ),
        ],
        if (_areaId != null) ...[
          const SizedBox(height: 16),
          ref
              .watch(placesProvider(_areaId!))
              .when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => _RetryButton(
                  what: 'places',
                  onRetry: () => ref.invalidate(placesProvider),
                ),
                data: (list) => AppDropdownField<int>(
                  key: ValueKey('place-$_areaId-$_placeId'),
                  label: 'Town or village',
                  hint: 'Choose your town or village',
                  initialValue: _placeId,
                  items: [
                    for (final p in list)
                      DropdownMenuItem<int>(value: p.id, child: Text(p.name)),
                    const DropdownMenuItem<int>(
                      value: _notListed,
                      child: Text('My place is not listed'),
                    ),
                  ],
                  onChanged: _selectPlace,
                  validator: (v) => v == null
                      ? 'Choose your town or village, or add it.'
                      : null,
                ),
              ),
        ],
        if (adding) ...[
          const SizedBox(height: 16),
          AppTextField(
            label: 'Name of your town or village',
            hint: 'e.g. Qunu',
            controller: _newName,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final text = v?.trim() ?? '';
              if (text.length < 2) {
                return 'Enter the place name (at least 2 letters).';
              }
              if (text.length > 60) return 'Keep the name under 60 characters.';
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.what, required this.onRetry});

  final String what;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onRetry,
      child: Text('Could not load $what. Tap to try again.'),
    );
  }
}
