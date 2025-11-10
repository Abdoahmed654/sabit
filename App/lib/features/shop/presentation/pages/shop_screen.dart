import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_event.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_state.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final ShopBloc _shopBloc;

  @override
  void initState() {
    super.initState();
    _shopBloc = di.sl<ShopBloc>();
    _shopBloc.add(const LoadShopItemsEvent());
  }

  @override
  void dispose() {
    _shopBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: Colors.purple,
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
      body: BlocConsumer<ShopBloc, ShopState>(
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
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ShopItemsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _shopBloc.add(const LoadShopItemsEvent());
              },
              child: _buildShopContent(state),
            );
          }

          return const Center(
            child: Text('Pull to refresh'),
          );
        },
      ),
    );
  }

  Widget _buildShopContent(ShopItemsLoaded state) {
    // Group items by type
    final hairItems = state.items.where((i) => i.type == ItemType.HAIR).toList();
    final clothItems = state.items.where((i) => i.type == ItemType.CLOTH).toList();
    final accessoryItems = state.items.where((i) => i.type == ItemType.ACCESSORY).toList();
    final shoeItems = state.items.where((i) => i.type == ItemType.SHOES).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Customize Your Character',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Purchase items with coins to customize your avatar',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        if (hairItems.isNotEmpty) ...[
          _buildCategoryHeader('Hair', Icons.face),
          _buildItemsGrid(hairItems, state),
          const SizedBox(height: 24),
        ],
        if (clothItems.isNotEmpty) ...[
          _buildCategoryHeader('Clothing', Icons.checkroom),
          _buildItemsGrid(clothItems, state),
          const SizedBox(height: 24),
        ],
        if (accessoryItems.isNotEmpty) ...[
          _buildCategoryHeader('Accessories', Icons.watch),
          _buildItemsGrid(accessoryItems, state),
          const SizedBox(height: 24),
        ],
        if (shoeItems.isNotEmpty) ...[
          _buildCategoryHeader('Shoes', Icons.shopping_bag),
          _buildItemsGrid(shoeItems, state),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(List<ShopItem> items, ShopItemsLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = state.inventory.any((ui) => ui.item.id == item.id);
        return _buildItemCard(item, isOwned);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, bool isOwned) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isOwned ? null : () => _showPurchaseDialog(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _getRarityColor(item.rarity).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 64),
                      )
                    : const Icon(Icons.shopping_bag, size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'OWNED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${item.priceCoins}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
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

  void _showPurchaseDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Purchase ${item.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${item.priceCoins} coins'),
            if (item.priceXp > 0) Text('Requires: ${item.priceXp} XP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _shopBloc.add(BuyItemEvent(item.id));
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}

