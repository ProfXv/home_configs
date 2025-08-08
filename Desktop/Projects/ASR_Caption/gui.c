#include "gui.h"
#include <stdlib.h>
#include <string.h>
#include <glib/gstdio.h>
#include <wordexp.h>
#include <time.h>

static GtkUi *global_ui = NULL;

// Forward declarations
static void handle_asr_completion(GtkUi *ui);
static void stream_model_output(GtkUi *ui);
static void execute_paste(const char* text);


// --- Utility Functions ---
static char* expand_path(const char* path) {
    wordexp_t p;
    char* expanded_path = NULL;
    if (wordexp(path, &p, 0) == 0) {
        if (p.we_wordc > 0) expanded_path = g_strdup(p.we_wordv[0]);
        wordfree(&p);
    }
    return expanded_path;
}

static char* read_file_content(const char* path) {
    char *content = NULL;
    g_file_get_contents(path, &content, NULL, NULL);
    return content;
}

static void write_file_content(const char* path, const char* content) {
    g_file_set_contents(path, content, -1, NULL);
}

static void append_to_file(const char* path, const char* line) {
    FILE *f = fopen(path, "a");
    if (f) {
        fprintf(f, "%s\n", line);
        fclose(f);
    }
}

// --- GTK Thread-Safe Update Functions ---
static gboolean idle_update_label(gpointer user_data) {
    char** data = (char**)user_data;
    GtkLabel* label = GTK_LABEL(data[0]);
    char* text = data[1];
    gtk_label_set_text(label, text);
    g_free(text);
    g_free(data);
    return G_SOURCE_REMOVE;
}

void update_label_text(GtkWidget* label, const char* text) {
    char** data = g_new(char*, 2);
    data[0] = (char*)label;
    data[1] = g_strdup(text);
    g_idle_add(idle_update_label, data);
}

void update_reference_text(const char* text) { if (global_ui) update_label_text(global_ui->reference_label, text); }
void update_asr_text(const char* text) { if (global_ui) update_label_text(global_ui->asr_label, text); }
void update_model_text(const char* text) { if (global_ui) update_label_text(global_ui->model_label, text); }

// --- Paste Execution (Simplified Synchronous Logic) ---
static void execute_paste(const char* text) {
    // Step 1: Copy text to clipboard using a blocking popen() call.
    FILE *pipe = popen("/usr/bin/wl-copy", "w");
    if (pipe) {
        fputs(text, pipe);
        pclose(pipe); // This waits for wl-copy to finish.
    }

    // Step 2: Now that copy is guaranteed to be finished, simulate Ctrl+V.
    gchar *yd_argv[] = {"/usr/bin/ydotool", "key", "29:1", "47:1", "47:0", "29:0", NULL};
    GPid pid;
    g_spawn_async(NULL, yd_argv, NULL, G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, &pid, NULL);
    g_child_watch_add(pid, (GChildWatchFunc)g_spawn_close_pid, NULL);
}


// --- Model Streaming Logic ---
static void cleanup_and_finalize(GtkUi *ui, GIOChannel *stdout_ch, GIOChannel *stderr_ch) {
    if (ui->final_model_output && ui->final_model_output->len > 0) {
        char* final_text = g_strdup(ui->final_model_output->str);
        write_file_content("/tmp/words", final_text);
        execute_paste(final_text);
        g_free(final_text);
        g_application_quit(G_APPLICATION(ui->app));
    } else {
        update_model_text("处理完成 (无输出)");
        g_timeout_add(2000, (GSourceFunc)g_application_quit, ui->app);
    }

    if (ui->final_model_output) g_string_free(ui->final_model_output, TRUE);
    if (stdout_ch) g_io_channel_unref(stdout_ch);
    if (stderr_ch) g_io_channel_unref(stderr_ch);
}

static gboolean on_model_error_received(GIOChannel *source, GIOCondition cond, gpointer data) {
    gchar *buf = NULL;
    if (g_io_channel_read_line(source, &buf, NULL, NULL, NULL) == G_IO_STATUS_NORMAL) {
        char* error_msg = g_strconcat("错误: ", buf, NULL);
        update_model_text(error_msg);
        g_free(error_msg);
        g_free(buf);
    }
    if (cond & G_IO_HUP) return G_SOURCE_REMOVE;
    return G_SOURCE_CONTINUE;
}

static gboolean on_model_data_received(GIOChannel *source, GIOCondition cond, gpointer data) {
    GtkUi *ui = (GtkUi*)data;
    gchar *buf = NULL;
    if (cond & G_IO_HUP) {
        cleanup_and_finalize(ui, source, NULL);
        return G_SOURCE_REMOVE;
    }
    if (g_io_channel_read_line(source, &buf, NULL, NULL, NULL) == G_IO_STATUS_NORMAL) {
        g_string_append(ui->final_model_output, buf);
        update_model_text(ui->final_model_output->str);
        g_free(buf);
    }
    return G_SOURCE_CONTINUE;
}

static void stream_model_output(GtkUi *ui) {
    char* ref_content = read_file_content("/tmp/words");
    char* prompt = g_strconcat(ui->current_result, "\n\"\"\"\n", ref_content ? ref_content : "", "\"\"\"\n", NULL);
    g_free(ref_content);

    gint out_fd, err_fd;
    GPid pid;
    gchar *argv[] = {
        "/usr/bin/stdbuf", "-o0",
        "gemini",
        "--allowed-mcp-server-names",
        "-m", "gemini-2.5-flash",
        "-p", prompt,
        NULL
    };
    g_spawn_async_with_pipes(NULL, argv, NULL, G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, &pid, NULL, &out_fd, &err_fd, NULL);
    g_free(prompt);

    GIOChannel *out_ch = g_io_channel_unix_new(out_fd);
    GIOChannel *err_ch = g_io_channel_unix_new(err_fd);
    g_io_add_watch(out_ch, G_IO_IN | G_IO_HUP, on_model_data_received, ui);
    g_io_add_watch(err_ch, G_IO_IN | G_IO_HUP, on_model_error_received, ui);
    
    ui->final_model_output = g_string_new("");
    update_model_text("正在调用模型...");
}

// --- Post-ASR Logic ---
static void handle_asr_completion(GtkUi *ui) {
    char* count_path = expand_path("~/.daily/speak_count");
    char* words_path = expand_path("~/.words.txt");
    if (count_path) {
        char* count_str = read_file_content(count_path);
        int count = count_str ? atoi(count_str) + 1 : 1;
        g_free(count_str);
        char new_count_str[12];
        sprintf(new_count_str, "%d", count);
        write_file_content(count_path, new_count_str);
        g_free(count_path);
    }
    if (words_path && ui->current_result) {
        time_t t = time(NULL);
        struct tm *tm = localtime(&t);
        char time_buf[64];
        strftime(time_buf, sizeof(time_buf), "%F %T", tm);
        char* log_line = g_strconcat(time_buf, "\t", ui->current_result, NULL);
        append_to_file(words_path, log_line);
        g_free(log_line);
        g_free(words_path);
    }

    const char* mode = (ui->argc > 1) ? ui->argv[1] : "default";

    if (strcmp(mode, "simple") == 0) {
        write_file_content("/tmp/words", ui->current_result);
        execute_paste(ui->current_result);
        g_application_quit(G_APPLICATION(ui->app));
    } else if (strcmp(mode, "complex") == 0) {
        stream_model_output(ui);
    } else {
        fprintf(stdout, "%s\n", ui->current_result ? ui->current_result : "");
        fflush(stdout);
        g_application_quit(G_APPLICATION(ui->app));
    }
}

// --- ASR Recognizer C-Callbacks ---
void on_result_gtk(const char *result, char is_last, void* user_data) {
    GtkUi *ui = (GtkUi*)user_data;
    if (result) {
        char* new_text = g_strconcat(ui->current_result ? ui->current_result : "", result, NULL);
        g_free(ui->current_result);
        ui->current_result = new_text;
        update_asr_text(ui->current_result);
    }
}

void on_speech_begin_gtk(void* user_data) {
    GtkUi *ui = (GtkUi*)user_data;
    g_free(ui->current_result);
    ui->current_result = NULL;
    update_asr_text("Listening...");
    update_model_text("");
}

void on_speech_end_gtk(int reason, void* user_data) {
    GtkUi *ui = (GtkUi*)user_data;
    handle_asr_completion(ui);
    g_free(ui->current_result);
    ui->current_result = NULL;
}

// --- UI Creation ---
GtkUi* create_ui(GtkApplication *app, int argc, char **argv) {
    global_ui = g_new0(GtkUi, 1);
    global_ui->app = app;
    global_ui->argc = argc;
    global_ui->argv = argv;

    global_ui->window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(global_ui->window), "ASRCaption");
    gtk_window_set_decorated(GTK_WINDOW(global_ui->window), FALSE);

    GtkWidget *overlay = gtk_overlay_new();
    gtk_window_set_child(GTK_WINDOW(global_ui->window), overlay);

    GtkWidget *vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_widget_set_valign(vbox, GTK_ALIGN_CENTER);
    gtk_overlay_set_child(GTK_OVERLAY(overlay), vbox);

    global_ui->reference_label = gtk_label_new(NULL);
    global_ui->asr_label = gtk_label_new("Initializing...");
    global_ui->model_label = gtk_label_new(NULL);

    gtk_label_set_wrap(GTK_LABEL(global_ui->reference_label), TRUE);
    gtk_label_set_wrap(GTK_LABEL(global_ui->asr_label), TRUE);
    gtk_label_set_wrap(GTK_LABEL(global_ui->model_label), TRUE);

    gtk_box_append(GTK_BOX(vbox), global_ui->reference_label);
    gtk_box_append(GTK_BOX(vbox), global_ui->asr_label);
    gtk_box_append(GTK_BOX(vbox), global_ui->model_label);

    const char* mode = (argc > 1) ? argv[1] : "default";
    if (strcmp(mode, "complex") != 0) {
        gtk_widget_set_visible(global_ui->reference_label, FALSE);
        gtk_widget_set_visible(global_ui->model_label, FALSE);
    } else {
        char* ref_content = read_file_content("/tmp/words");
        update_reference_text(ref_content ? ref_content : "(无参考内容)");
        g_free(ref_content);
    }

    GtkCssProvider *provider = gtk_css_provider_new();
    const char *css = 
        "window { background-color: transparent; }"
        "label {"
        "  color: white;"
        "  background-color: transparent;"
        "  font-family: 'Noto Sans';"
        "  font-size: 24px;"
        "  font-weight: bold;"
        "  padding: 15px;"
        "  border-radius: 10px;"
        "}";
    gtk_css_provider_load_from_string(provider, css);
    gtk_style_context_add_provider_for_display(gdk_display_get_default(), GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_USER);

    GdkRectangle workarea = {0};
    GdkDisplay *display = gdk_display_get_default();
    GListModel *monitors = gdk_display_get_monitors(display);
    GdkMonitor *monitor = GDK_MONITOR(g_list_model_get_item(monitors, 0));
    gdk_monitor_get_geometry(monitor, &workarea);
    
    int screen_width = workarea.width;
    int screen_height = workarea.height;
    int window_width = screen_width * 0.9;
    int window_height = screen_height * 0.2;
    
    gtk_window_set_default_size(GTK_WINDOW(global_ui->window), window_width, window_height);

    return global_ui;
}
