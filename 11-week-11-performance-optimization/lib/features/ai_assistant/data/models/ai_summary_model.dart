import '../../domain/entities/ai_summary.dart';

class AiSummaryModel extends AiSummary {
  const AiSummaryModel({
    required super.announcementId,
    required super.summary,
    required super.actionItems,
    required super.urgencyLevel,
    required super.generatedAt,
  });

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawActions = json['action_items'] as List<dynamic>? ?? [];
    final actionItems = rawActions.map((e) => e.toString()).toList();

    return AiSummaryModel(
      announcementId: json['announcement_id'] as String? ?? '',
      summary: json['summary'] as String? ?? 'Ringkasan tidak tersedia.',
      actionItems: actionItems,
      urgencyLevel: json['urgency_level'] as String? ?? 'Informasi',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement_id': announcementId,
      'summary': summary,
      'action_items': actionItems,
      'urgency_level': urgencyLevel,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
