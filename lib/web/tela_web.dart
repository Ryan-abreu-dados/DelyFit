import 'dart:async';

import 'package:flutter/material.dart';
import '../modelos/carrinho.dart';
import '../modelos/produto.dart';
import '../modelos/produtos_exemplo.dart';
import '../telas/tela_checkout.dart';

class TelaWeb extends StatefulWidget {
  const TelaWeb({super.key});

  @override
  State<TelaWeb> createState() => _TelaWebState();
}

class _TelaWebState extends State<TelaWeb> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _cardapioKey = GlobalKey();
  final GlobalKey _carrinhoKey = GlobalKey();

  final PageController _pageController = PageController(viewportFraction: 0.78);
  late final Timer _carouselTimer;

  final List<String> categorias = ['Todos', 'Low Carb', 'Vegano'];

  String selectedCategoria = 'Todos';
  late List<Produto> produtosFiltrados;

  @override
  void initState() {
    super.initState();
    produtosFiltrados = produtosExemplo;
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || produtosFiltrados.isEmpty) return;
      final nextPage = ((_pageController.page ?? _pageController.initialPage).round() + 1) % produtosFiltrados.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selecionarCategoria(String categoria) {
    setState(() {
      selectedCategoria = categoria;
      produtosFiltrados = categoria == 'Todos'
          ? produtosExemplo
          : produtosExemplo
              .where((produto) => produto.categoria == categoria)
              .toList();
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  void _mostrarDetalhesPopUp(Produto produto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(produto.nome, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  produto.imagem,
                  fit: BoxFit.cover,
                  height: 160,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300], height: 160),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                produto.macros,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(produto.descricao),
              const SizedBox(height: 16),
              Text('Categoria: ${produto.categoria}'),
              const SizedBox(height: 8),
              Text(
                'Preço: R\$ ${produto.preco.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Carrinho.adicionar(produto);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${produto.nome} adicionado ao carrinho!'),
                  ),
                );
                setState(() {});
              },
              child: const Text('Adicionar ao carrinho'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DelyFit Web'),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: () => _scrollTo(_homeKey),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => _scrollTo(_cardapioKey),
            child: const Text(
              'Cardápio',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => _scrollTo(_carrinhoKey),
            child: const Text(
              'Carrinho',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            _buildCategoriasSection(),
            _buildCardapioSection(),
            _buildCarrinhoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      key: _homeKey,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo à DelyFit',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Entrega rápida de refeições saudáveis e saborosas para você manter a rotina com mais energia.',
            style: TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => _scrollTo(_cardapioKey),
                child: const Text('Ver cardápio'),
              ),
              OutlinedButton(
                onPressed: () => _scrollTo(_carrinhoKey),
                child: const Text('Ir ao carrinho'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCheckout()),
                  );
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = produtosFiltrados[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _mostrarDetalhesPopUp(produto),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      elevation: 6,
                      child: InkWell(
                        onTap: () => _mostrarDetalhesPopUp(produto),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              produto.imagem,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.18),
                              colorBlendMode: BlendMode.darken,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[300]),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    Colors.black.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produto.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    produto.macros,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    onPressed: () =>
                                        _mostrarDetalhesPopUp(produto),
                                    child: const Text('Ver detalhes'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categorias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categorias.map((categoria) {
              return ChoiceChip(
                selected: selectedCategoria == categoria,
                label: Text(
                  categoria,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedCategoria == categoria
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                selectedColor: Colors.orange,
                backgroundColor: Colors.orange.shade100,
                onSelected: (_) => _selecionarCategoria(categoria),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardapioSection() {
    return Container(
      key: _cardapioKey,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cardápio',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          produtosFiltrados.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Nenhum item disponível para esta categoria.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produtosFiltrados.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return _buildProdutoCard(produtosFiltrados[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildProdutoCard(Produto produto) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                produto.imagem,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  produto.macros,
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${produto.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orange),
                      onPressed: () {
                        setState(() {
                          Carrinho.adicionar(produto);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${produto.nome} adicionado ao carrinho!',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrinhoSection() {
    return Container(
      key: _carrinhoKey,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carrinho',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Carrinho.itens.isEmpty
              ? const Text(
                  'Seu carrinho está vazio. Adicione itens do cardápio para avançar.',
                  style: TextStyle(fontSize: 16),
                )
              : Column(
                  children: Carrinho.itens
                      .map(
                        (item) => ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(item.nome),
                          trailing: Text(
                            'R\$ ${item.preco.toStringAsFixed(2)}',
                          ),
                        ),
                      )
                      .toList(),
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: R\$ ${Carrinho.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: Carrinho.itens.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaCheckout(),
                          ),
                        );
                      },
                child: const Text('Finalizar pedido'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
