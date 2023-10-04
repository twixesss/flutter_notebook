import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
  }

  void _saveAndPop() {
    final content = _controller.text;
    if (content.trim().isNotEmpty) {
      final title = content.split("\n").first;
      final truncatedTitle = title.length > 20 ? title.substring(0, 20) : title;
      Provider.of<NoteProvider>(context, listen: false)
          .updateNote(widget.note.id, truncatedTitle, content);
    }
    Navigator.pop(context);
  }

  void _deleteAndPop() {
    Provider.of<NoteProvider>(context, listen: false)
        .deleteNote(widget.note.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveAndPop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Note'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _saveAndPop,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteAndPop,
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveAndPop,
            )
          ],
        ),
        body: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Enter your note here',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewNoteScreen extends StatefulWidget {
  @override
  _NewNoteScreenState createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _saveAndPop() {
    final content = _controller.text;
    if (content.trim().isNotEmpty) {
      final title = content.split("\n").first;
      final truncatedTitle = title.length > 20 ? title.substring(0, 20) : title;
      final newNote = Note(
        id: DateTime.now().toString(),
        title: truncatedTitle,
        content: content,
      );
      Provider.of<NoteProvider>(context, listen: false).addNote(newNote);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveAndPop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('New Note'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _saveAndPop,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveAndPop,
            )
          ],
        ),
        body: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Enter your note here',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => IconButton(
              icon: Icon(themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode),
              onPressed: themeProvider.toggleTheme,
            ),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) => Scrollbar(
          child: ReorderableListView.builder(
            itemCount: noteProvider.notes.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final movedNote = noteProvider.notes.removeAt(oldIndex);
              noteProvider.insertNoteAt(newIndex, movedNote);
            },
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];
              return ListTile(
                key: ValueKey(note.id),
                title: Text(note.title),
                trailing: Icon(Icons.drag_handle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(note: note),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewNoteScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
