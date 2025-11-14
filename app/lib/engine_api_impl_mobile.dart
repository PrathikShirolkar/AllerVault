import 'ffi_engine.dart';
import 'engine_api.dart';

class EngineApiImpl {
  Future<MealAnalysis> processMealPhoto(String imagePath) async {
    // Call Rust via FFI synchronously; wrap in Future for uniform API.
    final result = FfiEngine.processMealPhoto(imagePath);
    return Future.value(result);
  }
}

