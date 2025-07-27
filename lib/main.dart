import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gamen.dart';
import 'note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isDarkMode = prefs.getBool('darkMode');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                ThemeProvider(isDarkMode: isDarkMode ?? false)),
        ChangeNotifierProvider(create: (context) => NoteProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Simple Note App',
      theme: themeProvider.themeData,
      home: NoteListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoteListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          return ReorderableListView.builder(
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
          );
        },
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
  bool _isDarkMode;

  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;

  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDarkMode);
  }
}
