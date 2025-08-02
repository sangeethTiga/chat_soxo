class DropDownValue {
  DropDownValue({this.id, this.value});

  String? id;
  String? value;
  factory DropDownValue.fromJson(Map<String, dynamic> json) => DropDownValue(
        id: json['id'].toString(),
        value: json['value'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
      };
  @override
  String toString() {
    return value ?? '';
  }
}
