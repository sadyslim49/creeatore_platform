import 'package:js/js.dart';

@JS()
library firebase_interop;

@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(void Function(Function(T) resolve, Function reject) executor);
  external PromiseJsImpl then(Function(T) onFulfilled, [Function onRejected]);
}

@JS('firebase.auth')
class AuthJsImpl {
  external PromiseJsImpl<void> applyActionCode(String code);
  external PromiseJsImpl<dynamic> checkActionCode(String code);
  external PromiseJsImpl<void> confirmPasswordReset(String code, String newPassword);
} 