import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_event.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_state.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late final ShopBloc _shopBloc;
  late TabController _tabController;
  ShopItemsLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    _shopBloc = di.sl<ShopBloc>();
    _shopBloc.add(const LoadShopItemsEvent());
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shopBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Character'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${state.user.coins}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(
              child: Text('Please login to view your character'),
            );
          }

          return BlocConsumer<ShopBloc, ShopState>(
            bloc: _shopBloc,
            listener: (context, state) {
              if (state is ItemPurchased) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ShopError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, shopState) {
              if (shopState is ShopLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (shopState is ShopItemsLoaded) {
                return _buildSplitView(authState.user, shopState);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _shopBloc.add(const LoadShopItemsEvent());
                },
                child: ListView(
                  children: const [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Pull to refresh'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSplitView(user, ShopItemsLoaded state) {
    final equippedItems = state.inventory.where((ui) => ui.equipped).toList();
    final equippedHair =
        equippedItems.where((ui) => ui.item.type == ItemType.HAIR).firstOrNull;
    final equippedCloth =
        equippedItems.where((ui) => ui.item.type == ItemType.CLOTH).firstOrNull;
    final equippedAccessory = equippedItems
        .where((ui) => ui.item.type == ItemType.ACCESSORY)
        .firstOrNull;
    final equippedShoes =
        equippedItems.where((ui) => ui.item.type == ItemType.SHOES).firstOrNull;

    return Column(
      children: [
        // Upper Part: Character Display (40% of screen)
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepPurple.withOpacity(0.2),
                          child: Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatChip(Icons.emoji_events,
                                'Level ${user.level}', Colors.purple),
                            const SizedBox(width: 8),
                            _buildStatChip(
                                Icons.star, '${user.xp} XP', Colors.amber),
                            const SizedBox(width: 8),
                            _buildStatChip(Icons.monetization_on,
                                '${user.coins}', Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Equipped Items Section
                const Text(
                  'Equipped Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (equippedItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No items equipped',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/shop'),
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('Visit Shop'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildEquippedItemCard(
                      'Hair', Icons.face, equippedHair?.item),
                  _buildEquippedItemCard(
                      'Clothing', Icons.checkroom, equippedCloth?.item),
                  _buildEquippedItemCard(
                      'Accessory', Icons.watch, equippedAccessory?.item),
                  _buildEquippedItemCard(
                      'Shoes', Icons.shopping_bag, equippedShoes?.item),
                ],
              ],
            ),
          ),
        ),

        // Lower Part: Tab-based Shop (60% of screen)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: const [
                    Tab(icon: Icon(Icons.face), text: 'Hair'),
                    Tab(icon: Icon(Icons.checkroom), text: 'Clothes'),
                    Tab(icon: Icon(Icons.watch), text: 'Accessories'),
                    Tab(icon: Icon(Icons.shopping_bag), text: 'Shoes'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildShopTab(state, ItemType.HAIR),
                    _buildShopTab(state, ItemType.CLOTH),
                    _buildShopTab(state, ItemType.ACCESSORY),
                    _buildShopTab(state, ItemType.SHOES),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopTab(ShopItemsLoaded state, ItemType type) {
    final items = state.items.where((item) => item.type == type).toList();
    final ownedItemIds = state.inventory.map((ui) => ui.item.id).toSet();

    if (items.isEmpty) {
      return const Center(
        child: Text('No items available'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = ownedItemIds.contains(item.id);
        return _buildShopItemCard(item, isOwned);
      },
    );
  }

  Widget _buildShopItemCard(ShopItem item, bool isOwned) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.imageUrl != null)
            Image.network(
              item.imageUrl!,
              height: 80,
              width: 80,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80),
            )
          else
            const Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getRarityColor(item.rarity),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.rarity.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isOwned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'OWNED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _shopBloc.add(BuyItemEvent(item.id)),
              icon: const Icon(Icons.monetization_on, size: 16),
              label: Text('${item.priceCoins}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquippedItemCard(
      String category, IconData icon, ShopItem? item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(category),
        subtitle: Text(item?.name ?? 'None'),
        trailing: item != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRarityColor(item.rarity),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.rarity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.COMMON:
        return Colors.grey;
      case ItemRarity.RARE:
        return Colors.blue;
      case ItemRarity.EPIC:
        return Colors.purple;
      case ItemRarity.LEGENDARY:
        return Colors.orange;
    }
  }
}
