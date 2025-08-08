#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "qisr.h"
#include "msp_cmn.h"
#include "msp_errors.h"
#include "speech_recognizer.h"
#include "../../gui.h" // Include the new GTK UI header

// This C file is now part of a C/C++ project.
// We need to ensure C linkage for the functions it exports.
#ifdef __cplusplus
extern "C" {
#endif

/* demo recognize the audio from microphone */
static void demo_mic(const char* session_begin_params, void* user_data)
{
	int errcode;

	struct speech_rec iat;
	
	// The notifier now points to our GTK-C-wrapper functions.
	// It also carries the `user_data` pointer, which points to our GtkUi struct instance.
	struct speech_rec_notifier recNotifier = {
		on_result_gtk,
		on_speech_begin_gtk,
		on_speech_end_gtk,
		user_data
	};

	errcode = sr_init(&iat, session_begin_params, SR_MIC, &recNotifier);
	if (errcode) {
		fprintf(stderr, "speech recognizer init failed\n");
		return;
	}
	errcode = sr_start_listening(&iat);
	if (errcode) {
		fprintf(stderr, "start listen failed %d\n", errcode);
	}

	// The application will now exit automatically when speech ends.
	// We can just sleep here to keep the thread alive.
	while(1) {
		sleep(3600); // Sleep for a long time
	}

	// The following code is now unreachable but kept for reference.
	// In a real application, you'd need a signal to break the loop.
	errcode = sr_stop_listening(&iat);
	if (errcode) {
		fprintf(stderr, "stop listening failed %d\n", errcode);
	}

	sr_uninit(&iat);
}

// The original `main` function is renamed to `run_asr_process`
// and will be called from our C `main.c` in a separate thread.
void run_asr_process(void* user_data)
{
	int ret = MSP_SUCCESS;
	
	char login_params[512];
	snprintf(login_params, sizeof(login_params), "appid = 3cda3e11, work_dir = %s/.local/share/ASRCaption", getenv("HOME"));

	/*
	* See "iFlytek MSC Reference Manual"
	*/
	const char* session_begin_params =
		"sub = iat, domain = iat, language = zh_cn, "
		"accent = mandarin, sample_rate = 16000, "
		"result_type = plain, result_encoding = utf8";

	/* Login first */
	ret = MSPLogin(NULL, NULL, login_params);
	if (MSP_SUCCESS != ret) {
		fprintf(stderr, "MSPLogin failed, Error code %d.\n", ret);
		return; // Exit the thread if login fails
	}

	fprintf(stderr, "ASR thread started. Demo recognizing the speech from microphone\n");

	// Pass the ui pointer to the demo function
	demo_mic(session_begin_params, user_data);

	MSPLogout(); // Logout... 
}

#ifdef __cplusplus
}
#endif
