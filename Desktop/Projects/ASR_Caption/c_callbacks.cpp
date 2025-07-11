#include "c_callbacks.h"
#include "controller.h"

#ifdef __cplusplus
extern "C" {
#endif

// Corrected argument order to match the header and the SDK's expectations.
void c_on_result(const char *result, char is_last, void* controller_ptr) {
    if (controller_ptr) {
        static_cast<Controller*>(controller_ptr)->handleResult(result, is_last);
    }
}

void c_on_speech_begin(void* controller_ptr) {
    if (controller_ptr) {
        static_cast<Controller*>(controller_ptr)->handleSpeechBegin();
    }
}

void c_on_speech_end(int reason, void* controller_ptr) {
    if (controller_ptr) {
        static_cast<Controller*>(controller_ptr)->handleSpeechEnd(reason);
    }
}

#ifdef __cplusplus
}
#endif