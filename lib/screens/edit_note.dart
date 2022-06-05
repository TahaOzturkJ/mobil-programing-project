import 'package:flutter/material.dart';
import 'package:NoteApp/code/code.dart';
import 'package:hive/hive.dart';
import 'package:NoteApp/data/hiveDB.dart';
import 'package:NoteApp/code/config.dart';

class EditNote extends StatelessWidget {
  final int noteKey;
  EditNote({required Key key, required this.noteKey}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Note note = Hive.box<Note>(notesBox)
        .values
        .singleWhere((value) => value.key == noteKey);
    _titleController.text = note.title;
    _descriptionController.text = note.description;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editing note"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Note info",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                  getDivider(),
                  title(),
                  getDivider(),
                  description(),
                  getDivider(),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Updated: ",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        Code().getDateFormated(note.dateUpdated),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  getDivider(),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Created: ",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        Code().getDateFormated(note.dateCreated),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  getDivider(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: OutlinedButton(
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              deleteNote(context);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: OutlinedButton(
                            child: const Text(
                              "Save",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              updateNoteInfo(note, context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateNoteInfo(Note note, context) async {
    if (_formKey.currentState!.validate()) {
      note.title = _titleController.text;
      note.description = _descriptionController.text;
      note.dateUpdated = DateTime.now();
      Box<Note> notes = Hive.box<Note>(notesBox);
      await notes.put(noteKey, note);
      Navigator.of(context).pop();
    }
  }

  deleteNote(context) async {
    Box<Note> notes = Hive.box<Note>(notesBox);
    await notes.delete(noteKey);
    Navigator.of(context).pop();
  }

  getDivider() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10.0),
    );
  }

  final TextEditingController _titleController = TextEditingController();
  title() {
    return TextFormField(
      controller: _titleController,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please fill the Note title";
        }
        return null;
      },
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          hintText: "Note title",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

  final TextEditingController _descriptionController = TextEditingController();
  description() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          hintText: "Note description (optional)",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }
}
