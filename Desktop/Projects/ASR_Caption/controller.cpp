#include "controller.h"
#include <QDebug>
#include <cstdio> // For fprintf, stdout

Controller::Controller(QObject *parent) : QObject(parent)
{
}

void Controller::handleResult(const char* result, bool is_last)
{
    if (result) {
        // Append new partial results
        currentResult.append(QString::fromUtf8(result));
        emit newResultReady(currentResult);
    }
}

void Controller::handleSpeechBegin()
{
    qDebug() << "Speech started, clearing previous result.";
    currentResult.clear();
    emit listeningStarted();
}

void Controller::handleSpeechEnd(int reason)
{
    qDebug() << "Speech ended with reason:" << reason;

    // Print the final, complete result to standard output, followed by a newline.
    if (!currentResult.isEmpty()) {
        fprintf(stdout, "%s\n", currentResult.toUtf8().constData());
        fflush(stdout); // Ensure the output is written immediately
    }

    emit listeningFinished(reason);
    // Reset the string for the next utterance.
    currentResult.clear();
}