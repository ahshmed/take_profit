class Market {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final bool isSelected;

  const Market({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isSelected = false,
  });

  Market copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    bool? isSelected,
  }) {
    return Market(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Market &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}