import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/product.dart';
import '../viewmodels/product_list_viewmodel.dart';
import '../widgets/product_skeleton.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListViewModel>().loadProducts();
    });
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          Consumer<ProductListViewModel>(
            builder: (_, vm, __) {
              final isRefreshing =
                  vm.state.status == ProductListStateStatus.refreshing;
              return IconButton(
                onPressed: isRefreshing
                    ? null
                    : () => vm.loadProducts(forceRefresh: true),
                icon: isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductListViewModel>(
        builder: (context, vm, _) {
          final state = vm.state;

          switch (state.status) {
            case ProductListStateStatus.idle:
            case ProductListStateStatus.loading:
              return const ProductSkeleton();

            case ProductListStateStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Erro desconhecido',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => vm.loadProducts(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );

            case ProductListStateStatus.empty:
              return const Center(child: Text('Nenhum produto encontrado.'));

            case ProductListStateStatus.success:
            case ProductListStateStatus.refreshing:
              return _ProductList(
                products: state.products,
                onTap: _openDetails,
              );
          }
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onTap;

  const _ProductList({required this.products, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.thumbnail,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade200,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          title: Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${product.category} • R\$ ${product.price.toStringAsFixed(2)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onTap(product),
        );
      },
    );
  }
}
