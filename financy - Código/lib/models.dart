import 'package:hive/hive.dart';

part 'models.g.dart'; // Será gerado automaticamente

// --- Modelo de Usuário ---
@HiveType(typeId: 0)
class Usuario extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String senhaHash; // Senha criptografada

  @HiveField(2)
  DateTime dataCriacao;

  Usuario({
    required this.email,
    required this.senhaHash,
    required this.dataCriacao,
  });
}

// --- Modelo de Transação ---
@HiveType(typeId: 1)
class TransacaoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId; // Email do usuário dono da transação

  @HiveField(2)
  String nome;

  @HiveField(3)
  double valor;

  @HiveField(4)
  int frequencia; // 0=diaria, 1=semanal, 2=mensal

  @HiveField(5)
  bool isDespesa;

  @HiveField(6)
  DateTime dataCriacao;

  TransacaoModel({
    required this.id,
    required this.userId,
    required this.nome,
    required this.valor,
    required this.frequencia,
    required this.isDespesa,
    required this.dataCriacao,
  });
}

// Enum para Frequência
enum Frequencia { diaria, semanal, mensal }