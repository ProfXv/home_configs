#include <gtk/gtk.h>
#include <pthread.h>
#include "gui.h"

// Forward declaration of the C function that runs the ASR process.
void run_asr_process(void* user_data);

// Forward declaration
static void activate(GtkApplication* app, gpointer user_data);

// Global variables to hold command-line arguments
static int global_argc;
static char **global_argv;

// Handle the command-line arguments
static int on_command_line(GApplication *app, GApplicationCommandLine *cmdline, gpointer user_data) {
    // The global argc and argv are already set from main().
    // We just need to activate the application to create the window.
    g_application_activate(app);
    return 0;
}

static void activate(GtkApplication* app, gpointer user_data) {
    // Create the UI, passing command-line arguments to it.
    GtkUi* ui = create_ui(app, global_argc, global_argv);

    // Run the C-based ASR logic in a separate thread.
    pthread_t asr_thread;
    if (pthread_create(&asr_thread, NULL, (void* (*)(void*))run_asr_process, ui)) {
        fprintf(stderr, "Error creating ASR thread\n");
        g_application_quit(G_APPLICATION(app));
        return;
    }
    pthread_detach(asr_thread);

    // Show the window.
    gtk_widget_set_visible(ui->window, TRUE);
}

int main(int argc, char *argv[]) {
    GtkApplication *app;
    int status;

    // Store command-line arguments globally so activate callback can access them
    global_argc = argc;
    global_argv = argv;

    app = gtk_application_new(NULL, G_APPLICATION_HANDLES_COMMAND_LINE);
    g_signal_connect(app, "command-line", G_CALLBACK(on_command_line), NULL);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}

