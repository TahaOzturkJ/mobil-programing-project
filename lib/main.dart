import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/hiveDB.dart';
import 'code/config.dart';
import 'screens/add_note.dart';
import "screens/edit_check_note.dart";
import 'screens/edit_note.dart';
import 'screens/edit_text_note.dart';

void main() async {
  if (!kIsWeb) {
    await Hive.initFlutter();
  }
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteTypeAdapter());
  Hive.registerAdapter(CheckListNoteAdapter());
  Hive.registerAdapter(TextNoteAdapter());
  await Hive.openBox<Note>(notesBox);
  await Hive.openBox<TextNote>(textNotesBox);
  await Hive.openBox<CheckListNote>(
      checkListNotesBox); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      title: appName,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("My Notes"),
          backgroundColor: const Color(0xff1321E0),
        ),
        body: SafeArea(child: getNotes()),
        floatingActionButton: addNoteButton(),
      ),
    );
  }

  getNotes() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Note>(notesBox).listenable(),
      builder: (context, Box<Note> box, _) {
        if (box.values.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Column(children: const [
                Icon(
                  Icons.dashboard,
                  size: 150,
                  color: Colors.blueGrey,
                ),
                Text(
                  "No Notes :(",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("You have no task to do.")
              ]),
            ),
          );
        }
        List<Note> notes = getNotesList();
        return ReorderableListView(
            onReorder: (oldIndex, newIdenx) async {
              await reorderNotes(oldIndex, newIdenx, notes);
            },
            children: <Widget>[
              for (Note note in notes) ...[
                getNoteInfo(note, context),
              ],
            ]);
      },
    );
  }

  reorderNotes(oldIndex, newIdenx, notes) async {
    Box<Note> hiveBox = Hive.box<Note>(notesBox);
    if (oldIndex < newIdenx) {
      notes[oldIndex].position = newIdenx - 1;
      await hiveBox.put(notes[oldIndex].key, notes[oldIndex]);
      for (int i = oldIndex + 1; i < newIdenx; i++) {
        notes[i].position = notes[i].position - 1;
        await hiveBox.put(notes[i].key, notes[i]);
      }
    } else {
      notes[oldIndex].position = newIdenx;
      await hiveBox.put(notes[oldIndex].key, notes[oldIndex]);
      for (int i = newIdenx; i < oldIndex; i++) {
        notes[i].position = notes[i].position + 1;
        await hiveBox.put(notes[i].key, notes[i]);
      }
    }
  }

  getNotesList() {
    //get notes as a List
    List<Note> notes = Hive.box<Note>(notesBox).values.toList();
    notes = getNotesSortedByOrder(notes);
    return notes;
  }

  getNotesSortedByOrder(List<Note> notes) {
    //ordering note list by position
    notes.sort((a, b) {
      var aposition = a.position;
      var bposition = b.position;
      return aposition.compareTo(bposition);
    });
    return notes;
  }

  getNoteInfo(Note note, BuildContext context) {
    return ListTile(
      dense: true,
      key: Key(note.key.toString()),
      onTap: () {
        if (note.noteType == NoteType.Text) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTextNote(
                noteParent: note.key,
                noteTitle: note.title,
                key: Key(note.key.toString()),
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditCheckNote(
                noteParent: note.key,
                noteTitle: note.title,
                key: Key(note.key.toString()),
              ),
            ),
          );
        }
      },
      title: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.black,
        ),
        child: Text(
          note.title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.info, size: 22, color: Colors.blueAccent),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditNote(
                noteKey: note.key,
                key: Key(note.key.toString()),
              ),
            ),
          );
        },
      ),
    );
  }

  addNoteButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          backgroundColor: const Color(0xff1321E0),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddNote()));
          },
        );
      },
    );
  }
}
