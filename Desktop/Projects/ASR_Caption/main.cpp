#include <QGuiApplication> // Use QGuiApplication for desktop file name
#include <QApplication>
#include <thread>
#include "gui.h"
#include "controller.h"

// Forward declaration of the C function that runs the ASR process.
// This function will be the original `main` function, but renamed.
extern "C" {
    void run_asr_process(void* controller);
}

int main(int argc, char *argv[])
{
    // This needs to be set before the QApplication is instantiated.
    QGuiApplication::setDesktopFileName("ASRCaption.desktop");

    QApplication app(argc, argv);

    ASRCaption window;
    
    // Set the window title to match the class name.
    window.setWindowTitle("ASRCaption");

    Controller controller;

    // Connect the controller's signals to the window's slots
    QObject::connect(&controller, &Controller::newResultReady,
                     &window, &ASRCaption::updateRecognitionResult);
    QObject::connect(&controller, &Controller::listeningStarted,
                     &window, [&]() { window.setListeningState(true); });
    QObject::connect(&controller, &Controller::listeningFinished,
                     &window, [&]() { window.setListeningState(false); });
    // Automatically quit the application when recognition is finished.
    QObject::connect(&controller, &Controller::listeningFinished,
                     &app, &QApplication::quit);


    // Run the C-based ASR logic in a separate thread to avoid blocking the GUI.
    // We pass a pointer to the controller object so the C code can call back into C++.
    std::thread asr_thread(run_asr_process, &controller);
    asr_thread.detach(); // Let the thread run independently.

    window.show();

    return app.exec();
}
