import 'package:flutter/material.dart';

class AboutLogeNote extends StatelessWidget {
  const AboutLogeNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Log Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Notes Features',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.tag),
              title: Text('Tags'),
              subtitle: Text('Add tags to your notes to easily organize and find them.'),
            ),
            const ListTile(
              leading: Icon(Icons.search),
              title: Text('Search'),
              subtitle: Text('Search through all your notes by keyword or tag.'),
            ),
            const ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archive'),
              subtitle: Text('Archive notes to keep your main screen clean.'),
            ),
            const ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
              subtitle: Text('Organize your notes into different categories.'),
            ),
          ],
        ),
      ),
    );
  }
}
