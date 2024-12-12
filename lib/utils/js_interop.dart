@JS()
library js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS('Promise')
external dynamic get Promise;

@JS('Object')
class Object {
  external static dynamic defineProperty(
      dynamic o, String p, PropertyDescriptor attributes);
}

@JS()
@anonymous
class PropertyDescriptor {
  external factory PropertyDescriptor({
    bool? configurable,
    bool? enumerable,
    dynamic value,
    bool? writable,
  });
}

@JS('JSON.stringify')
external String stringify(dynamic obj);

@JS('JSON.parse')
external dynamic parse(String str);

mixin JsInteropUtils {
  Future<T> handleThenable<T>(dynamic jsPromise) {
    if (jsPromise == null) {
      return Future<T>.value();
    }
    return promiseToFuture<T>(jsPromise);
  }

  dynamic jsifyData(dynamic data) {
    if (data == null) return null;
    return jsify(data);
  }

  dynamic dartifyData(dynamic jsObject) {
    if (jsObject == null) return null;
    return dartify(jsObject);
  }
}

// Make sure all classes that need JS interop extend this mixin
class StorageReference with JsInteropUtils {
  // ... existing code ...
}

class UploadTask with JsInteropUtils {
  // ... existing code ...
}

class _SettableMetadataBase<T> with JsInteropUtils {
  // ... existing code ...
}
