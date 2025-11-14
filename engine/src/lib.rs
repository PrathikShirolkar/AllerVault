mod pipeline;
pub mod types;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use types::MealAnalysis;

pub fn process_meal_photo(image_path: String) -> MealAnalysis {
    pipeline::run_pipeline(&image_path)
}

// C ABI for Dart FFI (mobile/desktop). Returns a heap-allocated C string with JSON.
// Caller (Dart) must free it using the provided free function.
#[no_mangle]
pub extern "C" fn process_meal_photo_ffi(path_ptr: *const c_char) -> *mut c_char {
    if path_ptr.is_null() {
        let json = serde_json::json!({"error":"null_path"}).to_string();
        return CString::new(json).unwrap().into_raw();
    }
    let cstr = unsafe { CStr::from_ptr(path_ptr) };
    let path = match cstr.to_str() {
        Ok(s) => s.to_string(),
        Err(_) => {
            let json = serde_json::json!({"error":"invalid_utf8_path"}).to_string();
            return CString::new(json).unwrap().into_raw();
        }
    };
    let result = process_meal_photo(path);
    let json = serde_json::to_string(&result).unwrap_or_else(|_| "{}".to_string());
    CString::new(json).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn engine_string_free(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        let _ = CString::from_raw(ptr);
    }
}
