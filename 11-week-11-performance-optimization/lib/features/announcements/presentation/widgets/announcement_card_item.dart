import 'package:flutter/material.dart';

import '../../../ai_assistant/presentation/widgets/ai_summary_modal.dart';
import '../../domain/entities/announcement.dart';

/// Leaf Widget terisolasi yang dioptimasi dengan RepaintBoundary dan const constructor
/// untuk mencegah jank serta meminimalisir frame rebuild saat scrolling.
class AnnouncementCardItem extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCardItem({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary mengisolasi render canvas item ini dari widget lain
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFE8EAF6), // Indigo 50
            child: Icon(
              Icons.campaign,
              color: Colors.indigo,
            ),
          ),
          title: Text(
            announcement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              announcement.body,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.black87,
              ),
            ),
          ),
          trailing: IconButton(
            key: Key('summarize_ai_button_${announcement.id}'),
            icon: const Icon(
              Icons.auto_awesome,
              color: Colors.indigo,
              size: 20,
            ),
            tooltip: 'Ringkas dengan AI',
            onPressed: () {
              AiSummaryModal.show(
                context,
                announcementId: announcement.id,
                title: announcement.title,
                body: announcement.body,
              );
            },
          ),
        ),
      ),
    );
  }
}

