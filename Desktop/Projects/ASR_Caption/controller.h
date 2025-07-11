#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QString>

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QObject *parent = nullptr);
    // Method to be called from C-style wrapper
    void handleResult(const char* result, bool is_last);
    void handleSpeechBegin();
    void handleSpeechEnd(int reason);

signals:
    void newResultReady(QString text);
    void listeningStarted();
    void listeningFinished(int reason);

private:
    QString currentResult;
};

#endif // CONTROLLER_H
