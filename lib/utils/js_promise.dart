import 'package:js/js.dart';

@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(void Function(Function(T) resolve, Function reject) executor);
  external PromiseJsImpl then(Function(T) onFulfilled, [Function onRejected]);
}
