class TabModel {
  final String id;
  final String title;
  final String? tooltip;
  final bool canClose;
  final Map<String, dynamic>? data;

  const TabModel({
    required this.id,
    required this.title,
    this.tooltip,
    this.canClose = true,
    this.data,
  });

  TabModel copyWith({
    String? id,
    String? title,
    String? tooltip,
    bool? canClose,
    Map<String, dynamic>? data,
  }) {
    return TabModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tooltip: tooltip ?? this.tooltip,
      canClose: canClose ?? this.canClose,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TabModel &&
      other.id == id &&
      other.title == title &&
      other.tooltip == tooltip &&
      other.canClose == canClose;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      tooltip.hashCode ^
      canClose.hashCode;
  }

  @override
  String toString() {
    return 'TabModel(id: $id, title: $title, tooltip: $tooltip, canClose: $canClose)';
  }
}