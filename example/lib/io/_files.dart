class FileName {
  factory FileName.fromFilePath(String path) {
    final fileName = path.split('/').last;
    return FileName(
      name: fileName.split('.').first,
      extension: fileName.split('.').last,
    );
  }

  const FileName({
    required this.name,
    required this.extension,
  });

  final String name;
  final String extension;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileName && runtimeType == other.runtimeType && name == other.name && extension == other.extension;

  @override
  int get hashCode => name.hashCode ^ extension.hashCode;
}
