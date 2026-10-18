import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/buyer_profile_page.dart';
import '../data/buyer_providers.dart';
import 'buyer_home_page.dart';
import 'search_page.dart';

/// The buyer's main frame: three tabs and a bottom navigation bar.
class BuyerShell extends ConsumerWidget {
  const BuyerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(buyerTabProvider);

    return Scaffold(
      // IndexedStack keeps every tab alive, so switching tabs does not
      // lose the search text or scroll position.
      body: IndexedStack(
        index: index,
        children: const [BuyerHomePage(), SearchPage(), BuyerProfilePage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(buyerTabProvider.notifier).select(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
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
