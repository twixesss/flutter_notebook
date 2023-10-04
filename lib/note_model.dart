import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  final String id;
  final String title;
  final String content;

  Note({required this.id, required this.title, required this.content});

  // NoteオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  // MapからNoteオブジェクトを作成
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteProvider() {
    loadNotes();
  }

  void addNote(Note note) {
    _notes.add(note);
    saveNotes();
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String newTitle, String newContent) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      _notes[noteIndex] = Note(id: id, title: newTitle, content: newContent);
      saveNotes();
      notifyListeners();
    }
  }

  void insertNoteAt(int index, Note note) {
    _notes.insert(index, note);
    saveNotes();
    notifyListeners();
  }

  // ノートを保存
  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = _notes.map((note) => note.toMap()).toList();
    prefs.setString('notes', json.encode(notesData));
  }

  // ノートを読み込み
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getString('notes');
    if (notesData != null) {
      final decodedData = json.decode(notesData) as List;
      _notes = decodedData.map((note) => Note.fromMap(note)).toList();
      notifyListeners();
    }
  }
}
