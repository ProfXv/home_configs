#ifndef C_CALLBACKS_H
#define C_CALLBACKS_H

#ifdef __cplusplus
extern "C" {
#endif

// Corrected argument order to match the speech_rec_notifier struct
void c_on_result(const char *result, char is_last, void* controller_ptr);
void c_on_speech_begin(void* controller_ptr);
void c_on_speech_end(int reason, void* controller_ptr);

#ifdef __cplusplus
}
#endif

#endif // C_CALLBACKS_H