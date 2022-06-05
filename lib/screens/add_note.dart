import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:NoteApp/data/hiveDB.dart';
import 'package:NoteApp/code/config.dart';
import 'package:share_plus/share_plus.dart';

class AddNote extends StatelessWidget {
  AddNote({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final String _content = "Note";

  void _shareContent() {
    Share.share(_content);
  }

  void _delete() {}
  void _duplicate() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xff1321E0),
          title: const Text("New Note"),
          actions: [
            IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 300,
                          color: const Color(0xff1321E0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                    onPressed: _shareContent,
                                    icon: const Icon(Icons.share),
                                    label:
                                        const Text('Share Twith your friends')),
                                ElevatedButton.icon(
                                    onPressed: _delete,
                                    icon: const Icon(Icons.delete),
                                    label: const Text("Delete")),
                                ElevatedButton.icon(
                                    onPressed: _delete,
                                    icon: const Icon(Icons.copy),
                                    label: const Text("Duplicate"))
                              ],
                            ),
                          ),
                        );
                      });
                }),
            IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  createTextNote(context);
                })
          ]),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  getDivider(),
                  title(),
                  getDivider(),
                  description(),
                  getDivider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        hintText: "Type Something...",
      ),
    );
  }

  final TextEditingController _descriptionController = TextEditingController();

  description() {
    return TextField(
      controller: _descriptionController,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        hintText: "Type Something...",
      ),
    );
  }

  createTextNote(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Box<Note> notes = Hive.box<Note>(notesBox);
      reorderNotes(notes);
      int pk = await notes.add(Note(DateTime.now(), _titleController.text,
          _descriptionController.text, DateTime.now(), NoteType.Text, 0));
      Box<TextNote> tNotes = Hive.box<TextNote>(textNotesBox);
      await tNotes.add(TextNote("", pk));
      Navigator.of(context).pop();
    }
  }

  createCheckListNote(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Box<Note> notes = Hive.box<Note>(notesBox);
      reorderNotes(notes);
      int pk = await notes.add(Note(DateTime.now(), _titleController.text,
          _descriptionController.text, DateTime.now(), NoteType.CheckList, 0));
      Box<CheckListNote> clNotes = Hive.box<CheckListNote>(checkListNotesBox);
      await clNotes.add(CheckListNote("", false, 0, pk));
      Navigator.of(context).pop();
    }
  }

  reorderNotes(Box<Note> notes) {
    for (Note noteOrder in notes.values) {
      noteOrder.position = noteOrder.position + 1;
      notes.put(noteOrder.key, noteOrder);
    }
  }
}
