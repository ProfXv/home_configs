#ifndef GUI_H
#define GUI_H

#include <gtk/gtk.h>

// A struct to hold pointers to the UI widgets that need to be updated.
typedef struct {
    GtkApplication *app;
    GtkWidget *window;
    GtkWidget *reference_label; // For text from /tmp/words
    GtkWidget *asr_label;       // For live ASR results
    GtkWidget *model_label;     // For streaming model output
    char *current_result;       // ASR partial result string
    int argc;
    char **argv;
    GString *final_model_output; // Buffer for streaming model output
} GtkUi;

// Initializes the GTK UI and returns a pointer to the GtkUi struct.
GtkUi* create_ui(GtkApplication *app, int argc, char **argv);

// Functions to be called from other threads to update the UI safely.
void update_asr_text(const char* text);
void update_model_text(const char* text);
void update_reference_text(const char* text);


// C-style callbacks for the speech recognizer
void on_result_gtk(const char *result, char is_last, void* user_data);
void on_speech_begin_gtk(void* user_data);
void on_speech_end_gtk(int reason, void* user_data);

#endif // GUI_H