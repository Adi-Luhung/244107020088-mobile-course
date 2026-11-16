class AiSummary {
  final String announcementId;
  final String summary;
  final List<String> actionItems;
  final String urgencyLevel; // 'Tinggi' | 'Sedang' | 'Informasi'
  final DateTime generatedAt;

  const AiSummary({
    required this.announcementId,
    required this.summary,
    required this.actionItems,
    required this.urgencyLevel,
    required this.generatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSummary &&
          runtimeType == other.runtimeType &&
          announcementId == other.announcementId &&
          summary == other.summary &&
          urgencyLevel == other.urgencyLevel;

  @override
  int get hashCode =>
      announcementId.hashCode ^ summary.hashCode ^ urgencyLevel.hashCode;
}
