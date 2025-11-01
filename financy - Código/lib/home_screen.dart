import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'storage_service.dart';
import 'models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<TransacaoLocal> transacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  // Carregar transações do usuário logado
  void _carregarTransacoes() {
    final transacoesDb = _storage.getTransacoesDoUsuario();
    setState(() {
      transacoes = transacoesDb.map((t) => TransacaoLocal(
        id: t.id,
        nome: t.nome,
        valor: t.valor,
        frequencia: Frequencia.values[t.frequencia],
        isDespesa: t.isDespesa,
      )).toList();
    });
  }

  Future<void> _removerTransacao(TransacaoLocal transacao) async {
    await _storage.removerTransacao(transacao.id);
    setState(() {
      transacoes.removeWhere((t) => t.id == transacao.id);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${transacao.nome} removid${transacao.isDespesa ? 'a' : 'o'}!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  double get totalDespesasMensais {
    double total = 0;
    for (var t in transacoes) {
      if (t.isDespesa) {
        if (t.frequencia == Frequencia.mensal) {
          total += t.valor;
        } else if (t.frequencia == Frequencia.semanal) {
          total += t.valor * 4;
        } else if (t.frequencia == Frequencia.diaria) {
          total += t.valor * 30;
        }
      }
    }
    return total;
  }

  double get totalReceitasMensais {
    double total = 0;
    for (var t in transacoes) {
      if (!t.isDespesa) {
        if (t.frequencia == Frequencia.mensal) {
          total += t.valor;
        } else if (t.frequencia == Frequencia.semanal) {
          total += t.valor * 4;
        } else if (t.frequencia == Frequencia.diaria) {
          total += t.valor * 30;
        }
      }
    }
    return total;
  }

  double get saldoTotal {
    return totalReceitasMensais - totalDespesasMensais;
  }

  Future<void> _adicionarTransacao(BuildContext context, {required bool isDespesa}) async {
    String nome = '';
    double valor = 0.0;
    Frequencia frequenciaSelecionada = Frequencia.mensal;
    
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isDespesa ? 'Nova Despesa' : 'Nova Receita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (text) => nome = text,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      onChanged: (text) => valor = double.tryParse(text) ?? 0.0,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Valor'),
                    ),
                    DropdownButtonFormField<Frequencia>(
                      initialValue: frequenciaSelecionada,
                      decoration: const InputDecoration(labelText: 'Frequência'),
                      items: Frequencia.values.map((Frequencia freq) {
                        return DropdownMenuItem<Frequencia>(
                          value: freq,
                          child: Text(freq.toString().split('.').last.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (Frequencia? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            frequenciaSelecionada = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nome.isNotEmpty && valor > 0) {
                      Navigator.of(context).pop({
                        'nome': nome,
                        'valor': valor,
                        'frequencia': frequenciaSelecionada,
                      });
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      // Salvar no banco de dados
      final userEmail = _storage.getUsuarioLogado()!;
      final novaTransacao = TransacaoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userEmail,
        nome: resultado['nome'],
        valor: resultado['valor'],
        frequencia: (resultado['frequencia'] as Frequencia).index,
        isDespesa: isDespesa,
        dataCriacao: DateTime.now(),
      );

      await _storage.adicionarTransacao(novaTransacao);
      _carregarTransacoes(); // Recarregar lista
    }
  }

  Future<void> _fazerLogout() async {
    await _storage.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final despesas = transacoes.where((t) => t.isDespesa).toList();
    final receitas = transacoes.where((t) => !t.isDespesa).toList();
    final bool isLargeScreen = MediaQuery.of(context).size.width > 700;
    final userEmail = _storage.getUsuarioLogado() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Gestão de Finanças'),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _fazerLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSaldoTotalCard(),
            const SizedBox(height: 16),

            isLargeScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildPieChartCard()),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildTransacaoSection(
                              title: 'Despesas',
                              color: Colors.red[700]!,
                              transacoes: despesas,
                              onAdd: () => _adicionarTransacao(context, isDespesa: true),
                              showRemoveButton: true,
                            ),
                            const SizedBox(height: 24),
                            _buildTransacaoSection(
                              title: 'Receitas',
                              color: Colors.green[700]!,
                              transacoes: receitas,
                              onAdd: () => _adicionarTransacao(context, isDespesa: false),
                              showRemoveButton: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildPieChartCard(),
                      const SizedBox(height: 24),
                      _buildTransacaoSection(
                        title: 'Despesas',
                        color: Colors.red[700]!,
                        transacoes: despesas,
                        onAdd: () => _adicionarTransacao(context, isDespesa: true),
                        showRemoveButton: false,
                      ),
                      const SizedBox(height: 24),
                      _buildTransacaoSection(
                        title: 'Receitas',
                        color: Colors.green[700]!,
                        transacoes: receitas,
                        onAdd: () => _adicionarTransacao(context, isDespesa: false),
                        showRemoveButton: false,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoTotalCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'SALDO TOTAL DO MÊS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${saldoTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: saldoTotal >= 0 ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueText('Receitas:', totalReceitasMensais, Colors.green),
                _buildValueText('Despesas:', totalDespesasMensais, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueText(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPieChartCard() {
    double total = totalReceitasMensais + totalDespesasMensais;
    if (total == 0) return const SizedBox.shrink();
    
    double despesaPercent = (totalDespesasMensais / total) * 100;
    double receitaPercent = (totalReceitasMensais / total) * 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Distribuição Mensal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: totalReceitasMensais,
                      title: '${receitaPercent.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: totalDespesasMensais,
                      title: '${despesaPercent.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransacaoSection({
    required String title,
    required Color color,
    required List<TransacaoLocal> transacoes,
    required VoidCallback onAdd,
    bool showRemoveButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        transacoes.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Nenhuma $title cadastrada ainda.', style: TextStyle(color: Colors.grey[600])),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transacoes.length,
                itemBuilder: (context, index) {
                  final t = transacoes[index];
                  String frequenciaTexto = t.frequencia.toString().split('.').last.toUpperCase();

                  Widget listItemContent = Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        t.isDespesa ? Icons.money_off : Icons.monetization_on,
                        color: color,
                      ),
                      title: Text(t.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Frequência: $frequenciaTexto'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${t.valor.toStringAsFixed(2)}',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (showRemoveButton)
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.grey),
                              onPressed: () => _removerTransacao(t),
                            ),
                        ],
                      ),
                    ),
                  );

                  return showRemoveButton 
                    ? listItemContent
                    : Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.withOpacity(0.8),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) => _removerTransacao(t),
                        child: listItemContent,
                      );
                },
              ),
      ],
    );
  }
}

// Classe auxiliar para uso local (não vai no banco)
class TransacaoLocal {
  final String id;
  final String nome;
  final double valor;
  final Frequencia frequencia;
  final bool isDespesa;

  TransacaoLocal({
    required this.id,
    required this.nome,
    required this.valor,
    required this.frequencia,
    required this.isDespesa,
  });
}