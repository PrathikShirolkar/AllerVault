import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

import 'engine_api.dart' show MealAnalysis, IngredientQuantity;

typedef _ProcessMealPhotoNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _EngineStringFreeNative = Void Function(Pointer<Utf8>);

class FfiEngine {
  static DynamicLibrary? _lib;
  static _ProcessMealPhotoNative? _process;
  static _EngineStringFreeNative? _free;

  static bool get isAvailable {
    try {
      _ensureLoaded();
      return _lib != null && _process != null && _free != null;
    } catch (_) {
      return false;
    }
  }

  static void _ensureLoaded() {
    if (_lib != null) return;
    DynamicLibrary lib;
    if (Platform.isAndroid) {
      lib = DynamicLibrary.open('libengine.so');
    } else if (Platform.isWindows) {
      lib = DynamicLibrary.open('engine.dll');
    } else if (Platform.isLinux || Platform.isFuchsia) {
      lib = DynamicLibrary.open('libengine.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      lib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('FFI not supported on this platform');
    }

    _lib = lib;
    _process = _lib!
        .lookup<NativeFunction<_ProcessMealPhotoNative>>('process_meal_photo_ffi')
        .asFunction();
    _free = _lib!
        .lookup<NativeFunction<_EngineStringFreeNative>>('engine_string_free')
        .asFunction();
  }

  static MealAnalysis processMealPhoto(String imagePath) {
    _ensureLoaded();
    final cPath = imagePath.toNativeUtf8();
    try {
      final ptr = _process!(cPath);
      final jsonStr = ptr.toDartString();
      _free!(ptr);
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      if (map.containsKey('error')) {
        throw Exception('Engine error: ${map['error']}');
      }
      final ingredients = (map['ingredients'] as List<dynamic>).cast<String>();
      final items = (map['ingredient_quantities'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => IngredientQuantity(
                name: e['name'] as String,
                amount: (e['amount'] as num).toDouble(),
                unit: e['unit'] as String,
              ))
          .toList();
      return MealAnalysis(
        dish: map['dish'] as String,
        quantity: map['quantity'] as String,
        ingredients: ingredients,
        ingredientQuantities: items,
      );
    } finally {
      malloc.free(cPath);
    }
  }
}

