class DropDownModel {
  const DropDownModel({
    this.id,
    this.value,
    this.code,
    this.projectSectionId,
  });

  final int? id;
  final String? value;
  final String? code;
  final int? projectSectionId;

  factory DropDownModel.fromJson(Map<String, dynamic> json) => DropDownModel(
        id: int.parse(json['id'].toString()),
        value: json['name'].toString(),
        code: json['code'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'code': code,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DropDownModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value);

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  String toString() => value ?? '';
}
