import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'models.dart';

class StorageService {
  static const String _usuariosBox = 'usuarios';
  static const String _transacoesBox = 'transacoes';
  static const String _currentUserKey = 'current_user';

  // Inicializar o Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Registrar adapters
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(TransacaoModelAdapter());
    
    // Abrir boxes
    await Hive.openBox<Usuario>(_usuariosBox);
    await Hive.openBox<TransacaoModel>(_transacoesBox);
    await Hive.openBox(_currentUserKey); // Box para guardar usuário logado
  }

  // --- AUTENTICAÇÃO ---

  // Criptografar senha
  String _hashSenha(String senha) {
    final bytes = utf8.encode(senha);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Cadastrar usuário
  Future<String?> cadastrarUsuario(String email, String senha) async {
    final box = Hive.box<Usuario>(_usuariosBox);
    
    // Verificar se usuário já existe
    if (box.values.any((u) => u.email == email)) {
      return 'Este e-mail já está cadastrado.';
    }

    // Validações
    if (!email.contains('@')) {
      return 'E-mail inválido.';
    }
    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    // Criar usuário
    final usuario = Usuario(
      email: email,
      senhaHash: _hashSenha(senha),
      dataCriacao: DateTime.now(),
    );

    await box.add(usuario);
    return null; // Sucesso
  }

  // Fazer login
  Future<String?> login(String email, String senha) async {
    final box = Hive.box<Usuario>(_usuariosBox);
    final senhaHash = _hashSenha(senha);

    // Procurar usuário
    try {
      final usuario = box.values.firstWhere(
        (u) => u.email == email && u.senhaHash == senhaHash,
      );

      // Salvar usuário atual
      final currentUserBox = Hive.box(_currentUserKey);
      await currentUserBox.put('email', email);

      return null; // Sucesso
    } catch (e) {
      return 'E-mail ou senha incorretos.';
    }
  }

  // Fazer logout
  Future<void> logout() async {
    final box = Hive.box(_currentUserKey);
    await box.clear();
  }

  // Verificar se há usuário logado
  String? getUsuarioLogado() {
    final box = Hive.box(_currentUserKey);
    return box.get('email');
  }

  // Verificar se está logado
  bool isLogado() {
    return getUsuarioLogado() != null;
  }

  // --- TRANSAÇÕES ---

  // Adicionar transação
  Future<void> adicionarTransacao(TransacaoModel transacao) async {
    final box = Hive.box<TransacaoModel>(_transacoesBox);
    await box.add(transacao);
  }

  // Listar transações do usuário logado
  List<TransacaoModel> getTransacoesDoUsuario() {
    final userEmail = getUsuarioLogado();
    if (userEmail == null) return [];

    final box = Hive.box<TransacaoModel>(_transacoesBox);
    return box.values
        .where((t) => t.userId == userEmail)
        .toList();
  }

  // Remover transação
  Future<void> removerTransacao(String transacaoId) async {
    final box = Hive.box<TransacaoModel>(_transacoesBox);
    final key = box.keys.firstWhere(
      (key) => box.get(key)?.id == transacaoId,
      orElse: () => null,
    );
    
    if (key != null) {
      await box.delete(key);
    }
  }

  // Limpar todas as transações do usuário (opcional)
  Future<void> limparTransacoesDoUsuario() async {
    final userEmail = getUsuarioLogado();
    if (userEmail == null) return;

    final box = Hive.box<TransacaoModel>(_transacoesBox);
    final keysToDelete = <dynamic>[];

    for (var key in box.keys) {
      final transacao = box.get(key);
      if (transacao?.userId == userEmail) {
        keysToDelete.add(key);
      }
    }

    await box.deleteAll(keysToDelete);
  }
}