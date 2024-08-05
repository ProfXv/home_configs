#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "qisr.h"
#include "msp_cmn.h"
#include "msp_errors.h"
#include "speech_recognizer.h"

#define FRAME_LEN	640
#define	BUFFER_SIZE	4096

/* Upload User words */
static int upload_userwords()
{
	char*			userwords	=	NULL;
	size_t			len			=	0;
	size_t			read_len	=	0;
	FILE*			fp			=	NULL;
	int				ret			=	-1;

	fp = fopen("userwords.txt", "rb");
	if (NULL == fp)
	{
		fprintf(stderr, "\nopen [userwords.txt] failed! \n");
		goto upload_exit;
	}

	fseek(fp, 0, SEEK_END);
	len = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	userwords = (char*)malloc(len + 1);
	if (NULL == userwords)
	{
		fprintf(stderr, "\nout of memory! \n");
		goto upload_exit;
	}

	read_len = fread((void*)userwords, 1, len, fp);
	if (read_len != len)
	{
		fprintf(stderr, "\nread [userwords.txt] failed!\n");
		goto upload_exit;
	}
	userwords[len] = '\0';

	MSPUploadData("userwords", userwords, len, "sub = uup, dtt = userword", &ret); //上传用户词表
	if (MSP_SUCCESS != ret)
	{
		fprintf(stderr, "\nMSPUploadData failed ! errorCode: %d \n", ret);
		goto upload_exit;
	}

upload_exit:
	if (NULL != fp)
	{
		fclose(fp);
		fp = NULL;
	}
	if (NULL != userwords)
	{
		free(userwords);
		userwords = NULL;
	}

	return ret;
}

static char *g_result = NULL;
static unsigned int g_buffersize = BUFFER_SIZE;

void on_result(const char *result, char is_last)
{
	if (result) {
		size_t left = g_buffersize - 1 - strlen(g_result);
		size_t size = strlen(result);
		if (left < size) {
			g_result = (char*)realloc(g_result, g_buffersize + BUFFER_SIZE);
			if (g_result)
				g_buffersize += BUFFER_SIZE;
			else {
				fprintf(stderr, "mem alloc failed\n");
				return;
			}
		}
		strncat(g_result, result, size);
		fprintf(stderr, "\rUpdated result: %s", g_result);
		fflush(stdout);
	}
}

void on_speech_begin()
{
	if (g_result)
	{
		free(g_result);
	}
	g_result = (char*)malloc(BUFFER_SIZE);
	g_buffersize = BUFFER_SIZE;
	memset(g_result, 0, g_buffersize);

	fprintf(stderr, "Start Listening...\n");
}

int speaking_done = 0;

void on_speech_end(int reason)
{
	if (reason == END_REASON_VAD_DETECT) {
		fprintf(stderr, "\nSpeaking done \n");
		speaking_done = 1;
		printf("%s", g_result);
	} else {
		fprintf(stderr, "\nRecognizer error %d\n", reason);
	}
}

/* demo recognize the audio from microphone */
static void demo_mic(const char* session_begin_params)
{
	int errcode;
	int i = 0;

	struct speech_rec iat;

	struct speech_rec_notifier recnotifier = {
		on_result,
		on_speech_begin,
		on_speech_end
	};

	errcode = sr_init(&iat, session_begin_params, SR_MIC, &recnotifier);
	if (errcode) {
		fprintf(stderr, "speech recognizer init failed\n");
		return;
	}
	errcode = sr_start_listening(&iat);
	if (errcode) {
		fprintf(stderr, "start listen failed %d\n", errcode);
	}
	/* demo 60 seconds recording */
	while(i++ < 60 && !speaking_done)
		sleep(1);
	errcode = sr_stop_listening(&iat);
	if (errcode) {
		fprintf(stderr, "stop listening failed %d\n", errcode);
	}

	sr_uninit(&iat);
}

int main(int argc, char* argv[])
{
	int ret = MSP_SUCCESS;
	/* login params, please do keep the appid correct */
	const char* login_params = "appid = 3cda3e11, work_dir = .";

	/*
	* See "iFlytek MSC Reference Manual"
	*/
	const char* session_begin_params =
		"sub = iat, domain = iat, language = zh_cn, "
		"accent = mandarin, sample_rate = 16000, "
		"result_type = plain, result_encoding = utf8";

	/* Login first. the 1st arg is username, the 2nd arg is password
	 * just set them as NULL. the 3rd arg is login paramertes
	 * */
	ret = MSPLogin(NULL, NULL, login_params);
	if (MSP_SUCCESS != ret) {
		fprintf(stderr, "MSPLogin failed , Error code %d.\n",ret);
		goto exit; // login fail, exit the program
	}

	fprintf(stderr, "Uploading the user words ...\n");
	/*
	ret = upload_userwords();
	if (MSP_SUCCESS != ret)
		goto exit;
	fprintf(stderr, "Uploaded successfully\n");
	*/

	fprintf(stderr, "Demo recognizing the speech from microphone\n");
	fprintf(stderr, "Speak in 60 seconds\n");

	demo_mic(session_begin_params);

exit:
	MSPLogout(); // Logout...

	return 0;
}

