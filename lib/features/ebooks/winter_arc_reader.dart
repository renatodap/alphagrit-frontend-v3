import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WinterArcReader extends StatelessWidget {
  const WinterArcReader({super.key});

  Future<String> _loadMarkdown(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/ebooks/winter_arc.md');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final md = snapshot.data ?? '# Winter Arc\nContent unavailable.';
        return Markdown(
          data: md,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            h1Align: WrapAlignment.start,
            h2Align: WrapAlignment.start,
          ),
        );
      },
    );
  }
}

