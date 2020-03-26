import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:mime_type/mime_type.dart';

CloudStorageBloc cloudStorageBloc = CloudStorageBloc();

class CloudStorageBloc {
  static const CLOUD_STORAGE_PATH = 'stokkie';

  StreamController<List<StorageTaskEvent>> _storageTaskEvents =
      StreamController.broadcast();
  List<StorageTaskEvent> _events = List();

  Stream<List<StorageTaskEvent>> get storageTaskEventStream =>
      _storageTaskEvents.stream;

  var meta = StorageMetadata(cacheControl: '36000');

  Future<String> uploadFile(File file) async {
    print('🌼🌼 CloudStorageBlocL uploadFile: 🌼 ${file.path} ... starting upload ....');
    assert(file != null);
    String mimeType = mime(file.path);
    print('🌼🌼 CloudStorageBlocL uploadFile: 🌼 mimeType: $mimeType');
    StorageReference _storageReference =
    FirebaseStorage().ref().child(CLOUD_STORAGE_PATH + '/${ DateTime.now().toUtc().millisecondsSinceEpoch}.jpg');
    var isSignedIn = await Auth.checkAuth();
    print('🌼🌼 CloudStorageBlocL uploadFile: 🌼 ... starting storageReference.putFile(file) ....isSignedIn: $isSignedIn');
    final StorageUploadTask uploadTask = _storageReference.putFile(file);
    final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      print(
          '🍎 StorageUploadTask 🍎 EVENT ${event.type} 🦠 bytesTransferred: ${event.snapshot.bytesTransferred} of totalByteCount: ${event.snapshot.totalByteCount}');
      _events.add(event);
      _storageTaskEvents.sink.add(_events);
    });

    print('🦠 🦠 🦠 StorageUploadTask ... waiting for completion ...');
    var snapshot = await uploadTask.onComplete;
    streamSubscription.cancel();
    var url = await snapshot.ref.getDownloadURL();
    print('🦠 🦠 🦠 StorageUploadTask returning url: 🔵 🔵 🔵 $url');
    return url;
  }

  void close() {
    _storageTaskEvents.close();
  }
}
