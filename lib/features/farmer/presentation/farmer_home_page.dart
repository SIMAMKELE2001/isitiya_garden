import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/data/auth_providers.dart';

/// Placeholder farmer dashboard. Add Produce, My Produce and Activity
/// arrive in Phase 6.
class FarmerHomePage extends ConsumerWidget {
  const FarmerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Molo, ${profile?.firstName ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed in as a farmer',
                    style: text.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  '${profile?.fullName ?? ''}\n${profile?.phone ?? ''}',
                  style: text.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your dashboard, Add Produce and listing management are coming in Phase 6.',
            style: text.bodyLarge?.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
