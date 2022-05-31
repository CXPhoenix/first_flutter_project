import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String appTitle = "Startup Name Generator";
    return MaterialApp(
      title: appTitle,
      home: const RandomWords(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _saved = <WordPair>{};
  void _removedSaved(WordPair pair) {
    setState(() {
      _saved.remove(pair);
    });
  }

  void _pushSaved() {
    // Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
    //   final tiles = _saved.map(
    //     (pair) {
    //       return Dismissible(
    //         key: Key(pair.toString()),
    //         child: ListTile(
    //           title: Text(
    //             pair.asPascalCase,
    //             style: _biggerFont,
    //           ),
    //           onTap: () => ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text(
    //                 "Swap To Remove",
    //                 textAlign: TextAlign.center,
    //                 style: _biggerFont,
    //               ),
    //             ),
    //           ),
    //         ),
    //         onDismissed: (direction) {
    //           setState(() {
    //             _saved.remove(pair);
    //           });
    //         },
    //       );
    //     },
    //   );
    //   final divided = tiles.isNotEmpty
    //       ? ListTile.divideTiles(tiles: tiles, context: context).toList()
    //       : <Widget>[];
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Saved Suggestions'),
    //     ),
    //     body: ListView(
    //       children: divided,
    //     ),
    //   );
    // }));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedSuggestions(
          saved: _saved,
          removedSaved: _removedSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Save Suggestions',
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) return const Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        return _buildRow(_suggestions[index]);
      },
      padding: const EdgeInsets.all(16.0),
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
}

class SavedSuggestions extends StatefulWidget {
  final Set<WordPair> saved;
  final Function removedSaved;
  const SavedSuggestions(
      {Key? key, required this.saved, required this.removedSaved})
      : super(key: key);

  @override
  State<SavedSuggestions> createState() => _SavedSuggestionsState();
}

class _SavedSuggestionsState extends State<SavedSuggestions> {
  final TextStyle _biggerfont = const TextStyle(fontSize: 18.0);
  showAlertDialog(BuildContext context, WordPair pair) {
    AlertDialog dialog = AlertDialog(
      title: Text("Remove From Saved Suggestions?"),
      content: Text(
          "Are you sure to remove '${pair.asPascalCase}' from saved suggestions?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.removedSaved(pair);
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '$pair is removed...',
                textAlign: TextAlign.center,
                style: _biggerfont,
              ),
              backgroundColor: Colors.black45,
              duration: const Duration(
                milliseconds: 500,
              ),
            ));
            Navigator.pop(context);
          },
          child: Text("Yes"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("No"),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = widget.saved.map(
      (pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerfont,
          ),
          onTap: () {
            showAlertDialog(context, pair);
          },
        );
      },
    );
    final divided =
        ListTile.divideTiles(tiles: tiles, context: context).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
      ),
      body: divided.isNotEmpty
          ? ListView(
              children: divided,
            )
          : Center(
              child: Text(
                "No Saved Suggestion...",
                style: _biggerfont,
              ),
            ),
    );
  }
}
