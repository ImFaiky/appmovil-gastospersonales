class CategoriaModel {
  int? id;
  String nombre;
  String tipo;
  String icono;
  String color;

  CategoriaModel({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.icono,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'icono': icono,
      'color': color,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      icono: map['icono'],
      color: map['color'],
    );
  }
}