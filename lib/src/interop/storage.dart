import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import '../../../utils/js_promise.dart';

// Create a mixin for handling JavaScript promises and conversions
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

// Apply the mixin to classes that need it
class StorageReference with JsInteropUtils {
  // ... existing code ...
}

class UploadTask with JsInteropUtils {
  // ... existing code ...
}

class _SettableMetadataBase<T> with JsInteropUtils {
  // ... existing code ...
}

// Add the mixin to any other classes that use handleThenable, jsify, or dartify

// Example usage:
final metadata = dartifyData(jsObject.customMetadata);
jsObject.customMetadata = jsifyData(metadata);