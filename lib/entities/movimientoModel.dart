class Movimientomodel {
  int? id;
  String tipo;
  double monto;
  String descripcion;
  DateTime fecha;
  int cuentaId;
  int categoriaId;

  Movimientomodel({
    this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.cuentaId,
    required this.categoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'cuentaId': cuentaId,
      'categoriaId': categoriaId,
    };
  }

  factory Movimientomodel.fromMap(Map<String, dynamic> map) {
    return Movimientomodel(
      id: map['id'],
      tipo: map['tipo'],
      monto: map['monto'],
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      cuentaId: map['cuentaId'],
      categoriaId: map['categoriaId'],
    );
  }
}
