class UsuarioModel {
  int? id;
  String nombre;
  int pin;

  UsuarioModel({this.id, required this.nombre, required this.pin});
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'pin': pin};
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(id: map['id'], nombre: map['nombre'], pin: map['pin']);
  }
}
