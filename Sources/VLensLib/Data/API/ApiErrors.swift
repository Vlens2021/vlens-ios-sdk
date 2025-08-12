//
//  ApiErrors.swift
//  VLens
//
//  Created by Mohamed Taher on 12/02/2025.
//


class SdkErrors {
    
    var apiErrors: [ApiError]
    
    init(apiErrors: [ApiError] = defaultApiErrors) {
        self.apiErrors = apiErrors
    }
    
    func get(by code: Int) -> String? {
        let apiError = apiErrors.first(where: { $0.errorCode == code })
        return apiError?.errorMessageEn
    }
}

struct ApiError {
    let errorCode: Int
    let errorMessageEn: String
    let errorMessageAr: String
}


let defaultApiErrors: [ApiError] = [
    ApiError(errorCode: 400, errorMessageEn: "Make sure all the required parameters are included.", errorMessageAr: "تأكد من تضمين جميع المعلمات المطلوبة."),
    ApiError(errorCode: 401, errorMessageEn: "Make sure you are using the correct credentials and try again.", errorMessageAr: "تأكد من أنك تستخدم بيانات الاعتماد الصحيحة وحاول مرة أخرى."),
    ApiError(errorCode: 403, errorMessageEn: "Generate and include a valid access token and try again.", errorMessageAr: "قم بإنشاء وتضمين رمز وصول صالح وحاول مرة أخرى."),
    ApiError(errorCode: 415, errorMessageEn: "Please re-check your image format.", errorMessageAr: "يرجى إعادة التحقق من تنسيق الصورة الخاصة بك."),
    ApiError(errorCode: 422, errorMessageEn: "Check the custom error code returned in the response, and refer to the Vlens Error Codes table for more information.", errorMessageAr: "تحقق من رمز الخطأ المخصص الذي تم إرجاعه في الاستجابة، وارجع إلى جدول رموز الأخطاء في Vlens لمزيد من المعلومات."),
    ApiError(errorCode: 500, errorMessageEn: "Well-formed request received, but an unexpected error has occurred. Try again later.", errorMessageAr: "تم استلام طلب منسق بشكل صحيح، ولكن حدث خطأ غير متوقع. حاول مرة أخرى لاحقًا."),
    ApiError(errorCode: 3001, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3002, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3003, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3004, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3005, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3006, errorMessageEn: "Error, Please make sure the document is in a good lighting condition and well focused.", errorMessageAr: "خطأ، يرجى التأكد من أن المستند في إضاءة جيدة ومركز بشكل جيد."),
    ApiError(errorCode: 3007, errorMessageEn: "Make sure dates in the ID are in correct format.", errorMessageAr: "تأكد من أن التواريخ في الهوية بالتنسيق الصحيح."),
    ApiError(errorCode: 3008, errorMessageEn: "Make sure dates in the ID are in correct format.", errorMessageAr: "تأكد من أن التواريخ في الهوية بالتنسيق الصحيح."),
    ApiError(errorCode: 3009, errorMessageEn: "Make sure dates in the ID are in correct format.", errorMessageAr: "تأكد من أن التواريخ في الهوية بالتنسيق الصحيح."),
    ApiError(errorCode: 3010, errorMessageEn: "Make sure the expiry date of the submitted document has not passed.", errorMessageAr: "تأكد من أن تاريخ انتهاء صلاحية المستند المقدم لم ينقض."),
    ApiError(errorCode: 3101, errorMessageEn: "ID number in ID front and back documents are not matched.", errorMessageAr: "رقم الهوية في المستندات الأمامية والخلفية للهوية غير متطابق."),
    ApiError(errorCode: 3102, errorMessageEn: "Name in ID front and car license documents are not matched.", errorMessageAr: "الاسم في المستندات الأمامية للهوية ورخصة السيارة غير متطابق."),
    ApiError(errorCode: 4001, errorMessageEn: "Please re-enter your bundle key correctly.", errorMessageAr: "يرجى إعادة إدخال مفتاح الحزمة الخاص بك بشكل صحيح."),
    ApiError(errorCode: 4002, errorMessageEn: "Please recharge your bundle and try again.", errorMessageAr: "يرجى إعادة شحن حزمة الخاص بك وحاول مرة أخرى."),
    ApiError(errorCode: 4003, errorMessageEn: "Number of trials exceeded the limit. Try again later.", errorMessageAr: "تجاوز عدد المحاولات الحد المسموح به. حاول مرة أخرى لاحقًا."),
    ApiError(errorCode: 4004, errorMessageEn: "Make sure the service being called is registered in your bundle.", errorMessageAr: "تأكد من أن الخدمة التي يتم استدعاؤها مسجلة في حزمة الخاص بك."),
    ApiError(errorCode: 4005, errorMessageEn: "The bundle has been disabled, please contact the server admin for re-activation.", errorMessageAr: "تم تعطيل الحزمة، يرجى الاتصال بمسؤول الخادم لإعادة التفعيل."),
    ApiError(errorCode: 4206, errorMessageEn: "Please make sure to have only one face in the image.", errorMessageAr: "يرجى التأكد من وجود وجه واحد فقط في الصورة."),
    ApiError(errorCode: 4207, errorMessageEn: "No Face detected", errorMessageAr: "لم يتم اكتشاف أي وجه"),
    ApiError(errorCode: 4208, errorMessageEn: "Please make sure that there is a face in the image.", errorMessageAr: "يرجى التأكد من وجود وجه في الصورة."),
    ApiError(errorCode: 4209, errorMessageEn: "Please recapture your face and ensure the capture is clear.", errorMessageAr: "يرجى إعادة التقاط صورتك والتأكد من أن الصورة واضحة."),
    ApiError(errorCode: 5000, errorMessageEn: "Something went wrong, please contact support", errorMessageAr: "حدث خطأ ما، يرجى الاتصال بالدعم"),
    ApiError(errorCode: 5001, errorMessageEn: "Please enter a supported document.", errorMessageAr: "يرجى إدخال مستند مدعوم."),
    ApiError(errorCode: 5002, errorMessageEn: "Make sure each provided image does not exceed the 5MB limit.", errorMessageAr: "تأكد من أن كل صورة مقدمة لا تتجاوز الحد الأقصى 5 ميجابايت."),
    ApiError(errorCode: 5003, errorMessageEn: "Make sure each provided image does not exceed the 25 Million pixel limit.", errorMessageAr: "تأكد من أن كل صورة مقدمة لا تتجاوز الحد الأقصى 25 مليون بكسل."),
    ApiError(errorCode: 7000, errorMessageEn: "A general error occurred while processing multiple cards.", errorMessageAr: "حدث خطأ عام أثناء معالجة بطاقات متعددة."),
    ApiError(errorCode: 7001, errorMessageEn: "A general error occurred while processing the front side of the ID card.", errorMessageAr: "حدث خطأ عام أثناء معالجة الجانب الأمامي من بطاقة الهوية."),
    ApiError(errorCode: 7002, errorMessageEn: "A general error occurred while processing the back side of the ID card.", errorMessageAr: "حدث خطأ عام أثناء معالجة الجانب الخلفي من بطاقة الهوية."),
    ApiError(errorCode: 7006, errorMessageEn: "A general error occurred while processing the passport.", errorMessageAr: "حدث خطأ عام أثناء معالجة جواز السفر."),
]

func getApiErrorMessage(_ errorCode: Int) -> String {
    return defaultApiErrors.first { $0.errorCode == errorCode }?.errorMessageEn ?? "Unknown error occurred."
}
