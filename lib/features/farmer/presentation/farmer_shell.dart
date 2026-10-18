import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../profile/presentation/farmer_profile_page.dart';
import '../data/farmer_providers.dart';
import 'farmer_home_page.dart';
import 'listing_form_page.dart';
import 'my_produce_page.dart';

/// The farmer's main frame: three tabs, plus a prominent
/// "Add produce" button on the first two.
class FarmerShell extends ConsumerWidget {
  const FarmerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(farmerTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          FarmerHomePage(),
          MyProducePage(),
          FarmerProfilePage(),
        ],
      ),
      floatingActionButton: index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openListingForm(context),
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF2A1D00),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add produce',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(farmerTabProvider.notifier).select(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'My produce',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
