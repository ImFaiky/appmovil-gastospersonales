class Cuentamodel {
  int? id;
  String nombre;
  String tipo;
  double saldo;
  String color;
  int usuarioId;

  Cuentamodel({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.saldo,
    required this.color,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'saldo': saldo,
      'color': color,
      'usuarioId': usuarioId,
    };
  }

  factory Cuentamodel.fromMap(Map<String, dynamic> map) {
    return Cuentamodel(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      saldo: map['saldo'],
      color: map['color'],
      usuarioId: map['usuarioId'],
    );
  }
}
