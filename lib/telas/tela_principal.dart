import 'dart:async';

import 'package:flutter/material.dart';
import '../modelos/produto.dart';
import '../modelos/produtos_exemplo.dart';
import 'tela_cardapio.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _cardapioKey = GlobalKey();
  final PageController _heroController = PageController(viewportFraction: 0.82);
  late final Timer _heroTimer;

  final List<String> _menuItems = ['Home', 'Cardápio', 'Carrinho'];
  final List<String> _categories = ['Todos', 'Low Carb', 'Vegano'];
  int _hoveredMenuIndex = -1;
  int _selectedCategoryIndex = 0;
  int _heroIndex = 0;
  late List<Produto> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = produtosExemplo;
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_heroController.hasClients || _filteredProducts.isEmpty) return;
      final nextIndex = (_heroIndex + 1) % _filteredProducts.length;
      _heroController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer.cancel();
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      final selectedCategory = _categories[index];
      _filteredProducts = selectedCategory == 'Todos'
          ? produtosExemplo
          : produtosExemplo
              .where((produto) => produto.categoria == selectedCategory)
              .toList();
      _heroController.jumpToPage(0);
      _heroIndex = 0;
    });
  }

  void _onHeroPageChanged(int index) {
    setState(() => _heroIndex = index);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      titleSpacing: 24,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_dining, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          const Text(
            'DelyFit',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
      actions: _menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final selected = _hoveredMenuIndex == index;
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredMenuIndex = index),
          onExit: (_) => setState(() => _hoveredMenuIndex = -1),
          cursor: SystemMouseCursors.click,
          child: TextButton(
            onPressed: () {
              if (label == 'Home') {
                _scrollTo(_heroKey);
              } else if (label == 'Cardápio') {
                _scrollTo(_cardapioKey);
              } else {
                _scrollTo(_cardapioKey);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: selected ? Colors.deepOrange : Colors.black54,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeroSection(double width) {
    final isWide = width > 1000;
    return Container(
      key: _heroKey,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      color: const Color(0xFFF9F0E8),
      child: Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: isWide ? 4 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refeições saudáveis com sabor premium',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(
                  width: 520,
                  child: Text(
                    'Descubra pratos nutritivos preparados para manter sua rotina energética e prática.',
                    style: TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => _scrollTo(_cardapioKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        // ignore: deprecated_member_use
                        shadowColor: Colors.deepOrange.withOpacity(0.35),
                      ),
                      child: const Text('Ver cardápio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCardapio()));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: BorderSide(color: Colors.deepOrange.shade100, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Abrir cards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28, width: 28),
          Expanded(
            flex: isWide ? 5 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 360,
                  child: PageView.builder(
                    controller: _heroController,
                    itemCount: _filteredProducts.length,
                    onPageChanged: _onHeroPageChanged,
                    itemBuilder: (context, index) {
                      final produto = _filteredProducts[index];
                      return _buildHeroCard(produto);
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _filteredProducts.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _heroIndex == index ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _heroIndex == index ? Colors.deepOrange : Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Produto produto) {
    return GestureDetector(
      onTap: () => _showProductDetails(produto),
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            // ignore: deprecated_member_use
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 10)),
          ],
          image: DecorationImage(
            image: NetworkImage(produto.imagem),
            fit: BoxFit.cover,
            // ignore: deprecated_member_use
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.22), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  // ignore: deprecated_member_use
                  colors: [Colors.black.withOpacity(0.62), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produto.nome, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(produto.macros, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showProductDetails(produto),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      elevation: 6,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.deepOrange.withOpacity(0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Ver detalhes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final selected = index == _selectedCategoryIndex;
          return ChoiceChip(
            selected: selected,
            label: Text(category, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black87)),
            selectedColor: Colors.deepOrange,
            backgroundColor: Colors.orange.shade50,
            side: BorderSide(color: selected ? Colors.deepOrange : Colors.orange.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            onSelected: (_) => _selectCategory(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridSection(double width) {
    final crossAxisCount = width > 1200 ? 3 : width > 800 ? 2 : 1;
    return Container(
      key: _cardapioKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cardápio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 240,
            ),
            itemBuilder: (context, index) {
              final produto = _filteredProducts[index];
              return _buildProductCard(produto);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Produto produto) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showProductDetails(produto),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    produto.imagem,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(produto.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(produto.macros, style: const TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(produto.descricao, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('R\$ ${produto.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () => _showProductDetails(produto),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Produto produto) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    produto.imagem,
                    fit: BoxFit.cover,
                    height: 260,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, height: 260),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(produto.nome, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(produto.macros, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 18),
                      Text(produto.descricao, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('R\$ ${produto.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${produto.nome} adicionado ao carrinho!')),
                              );
                            },
                            child: const Text('Adicionar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(constraints.maxWidth),
                _buildCategoryChips(),
                _buildGridSection(constraints.maxWidth),
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ),
    );
  }
}
