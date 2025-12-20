import 'dart:async';
import 'dart:io';

class ErrorHandler {
  static String parseError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return "تأكد من اتصالك بالإنترنت";
    }

    if (error is HttpException) {
      return "حدث خطأ في الاتصال بالخادم";
    }

    // Try to extract message from Exception objects strings
    String errorStr = error.toString();

    // Extract valid JSON error message if present
    // First, try to parse status code
    int? statusCode;
    final statusCodeMatch = RegExp(r'Error (\d+):').firstMatch(errorStr);
    if (statusCodeMatch != null) {
      statusCode = int.tryParse(statusCodeMatch.group(1)!);
    }

    // Specific Status Code Handling
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          // Often validation error, handled below by keyword matching, 
          // but return generic if no keyword matched later.
          // We let it fall through to keyword matching first.
          break;
        case 401:
          return "يرجى تسجيل الدخول مرة أخرى (401)";
        case 403:
          return "ليس لديك صلاحية للقيام بهذا الإجراء (403)";
        case 404:
          return "هذا المورد غير موجود أو تم حذفه (404)";
        case 405:
          return "الإجراء غير مسموح به (405)";
        case 408:
          return "انتهت مهلة الطلب، حاول مرة أخرى (408)";
        case 402:
          return "الرجاء إتمام الدفع للمتابعة (402)";
        case 409:
          return "تعارض في البيانات، ربما قمت بهذا الإجراء سابقاً (409)";
        case 429:
          return "طلبات كثيرة جداً، يرجى الانتظار قليلاً (429)";
        case 500:
          return "خطأ داخلي في الخادم، يرجى المحاولة لاحقاً (500)";
        case 502:
          return "الخادم غير متاح حالياً - Bad Gateway (502)";
        case 503:
          return "الخدمة غير متوفرة حالياً، يرجى المحاولة لاحقاً (503)";
        case 504:
          return "الخادم لا يستجيب - Gateway Timeout (504)";
      }
    }

    // Common Auth Errors (Fallback if regex failed or string doesn't match pattern)
    if (errorStr.contains("401") || errorStr.toLowerCase().contains("unauthorized")) {
      return "يرجى تسجيل الدخول مرة أخرى";
    }
    
    // Backend Validation Errors
    if (errorStr.contains("403") || errorStr.toLowerCase().contains("forbidden")) {
       return "ليس لديك صلاحية للوصول (403)";
    }
    
    // Continue with validation checks...
    if (errorStr.contains("FullName") && errorStr.contains("required")) {
      return "يرجى إدخال الاسم بالكامل";
    }
    if (errorStr.contains("PhoneNumber") && errorStr.contains("required")) {
      return "يرجى إدخال رقم الهاتف";
    }
    if (errorStr.contains("Password") && errorStr.contains("required")) {
      return "يرجى إدخال كلمة المرور";
    }
    
    // Check for common backend keywords
    if (errorStr.contains("One or more validation errors")) {
       // Detailed parsing could be done if the error object was passed as Map, 
       // but mostly we get a stringified exception here.
       return "يرجى التأكد من صحة البيانات المدخلة";
    }
    
    if (errorStr.contains("Password") && (errorStr.contains("Digit") || errorStr.contains("NonAlphanumeric"))) {
      return "كلمة المرور يجب أن تكون قوية (تحتوي على أرقام ورموز)";
    }

    if (errorStr.contains("Email") && (errorStr.contains("taken") || errorStr.contains("exists"))) {
      return "البريد الإلكتروني مسجل بالفعل";
    }
    
    if (errorStr.contains("PhoneNumber") && (errorStr.contains("taken") || errorStr.contains("exists"))) {
      return "رقم الهاتف مسجل بالفعل";
    }
    
    if (errorStr.contains("Login failed") || errorStr.contains("Invalid credentials")) {
        return "رقم الهاتف أو كلمة المرور غير صحيحة";
    }

    // Default fallback
    // Only show raw error in debug mode if needed, but for user return generic
    return "حدث خطأ غير متوقع ($errorStr)"; // Keep hint for now, or remove for production
    // Return simple: 
    // return "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";
  }
}
