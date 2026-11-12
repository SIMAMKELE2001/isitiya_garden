import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/info_row.dart';
import '../../auth/data/auth_providers.dart';
import '../../location/data/location_repository.dart';
import '../../farmer/data/farmer_providers.dart';
import 'edit_farmer_profile_page.dart';

/// Farmer Profile tab (FR04). This is what buyers learn about the farmer.
class FarmerProfilePage extends ConsumerWidget {
  const FarmerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final details = ref.watch(farmerDetailsProvider).value;
    final place = ref.watch(placeDetailsProvider(profile?.communityId)).value;
    final email = ref.watch(supabaseClientProvider).auth.currentUser?.email;
    final text = Theme.of(context).textTheme;

    final communityName = place == null
        ? 'Not set'
        : '${place.name}, ${place.areaName}, ${place.provinceName}';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.leaf,
                      child: Text(
                        profile.firstName.isEmpty
                            ? '?'
                            : profile.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            details?.farmName ?? 'Farmer',
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.agriculture_outlined,
                        label: 'Farm',
                        value: details?.farmName ?? 'Not set',
                      ),
                      InfoRow(
                        icon: Icons.place_outlined,
                        label: 'Community',
                        value: communityName,
                      ),
                      InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: profile.phone,
                      ),
                      InfoRow(
                        icon: Icons.chat_outlined,
                        label: 'WhatsApp number',
                        value: details?.whatsappNumber ?? 'Same as phone',
                      ),
                      InfoRow(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: email ?? 'Not available',
                      ),
                      if (details?.about != null &&
                          details!.about!.trim().isNotEmpty)
                        InfoRow(
                          icon: Icons.info_outline,
                          label: 'About',
                          value: details.about!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditFarmerProfilePage(
                        profile: profile,
                        details: details,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(farmerTabProvider);
                    ref.read(authRepositoryProvider).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ],
            ),
    );
  }
}
