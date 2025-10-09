// Minimal in-memory fake Firestore for tests.
class InMemoryFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> _data = {};

  Collection collection(String name) => Collection(this, name);
}

class Collection {
  final InMemoryFirestore _fs;
  final String name;
  Collection(this._fs, this.name) {
    _fs._data.putIfAbsent(name, () => {});
  }

  Doc doc([String? id]) {
    final docs = _fs._data[name]!;
    if (id == null || id.isEmpty) {
      id = 'id_\${DateTime.now().microsecondsSinceEpoch}';
    }
    docs.putIfAbsent(id, () => {});
    return Doc(_fs, name, id);
  }

  Future<QuerySnapshot> get() async {
    final docs = _fs._data[name]!;
    final list = docs.entries
        .map((e) => DocSnapshot(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
    return QuerySnapshot(list);
  }

  Stream<QuerySnapshot> snapshots() async* {
    yield await get();
  }
}

class Doc {
  final InMemoryFirestore _fs;
  final String name;
  final String id;
  Doc(this._fs, this.name, this.id);

  String get docId => id;

  Future<void> set(Map<String, dynamic> data) async {
    _fs._data[name]![id] = Map<String, dynamic>.from(data);
  }

  Future<void> delete() async {
    _fs._data[name]!.remove(id);
  }
}

class DocSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  DocSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class QuerySnapshot {
  final List<DocSnapshot> docs;
  QuerySnapshot(this.docs);
}

// Helper to create a fresh InMemoryFirestore instance for tests.
InMemoryFirestore createInMemoryFirestore() => InMemoryFirestore();
