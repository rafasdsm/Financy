// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 0;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      email: fields[0] as String,
      senhaHash: fields[1] as String,
      dataCriacao: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.senhaHash)
      ..writeByte(2)
      ..write(obj.dataCriacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransacaoModelAdapter extends TypeAdapter<TransacaoModel> {
  @override
  final int typeId = 1;

  @override
  TransacaoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransacaoModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      nome: fields[2] as String,
      valor: fields[3] as double,
      frequencia: fields[4] as int,
      isDespesa: fields[5] as bool,
      dataCriacao: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransacaoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.valor)
      ..writeByte(4)
      ..write(obj.frequencia)
      ..writeByte(5)
      ..write(obj.isDespesa)
      ..writeByte(6)
      ..write(obj.dataCriacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransacaoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
