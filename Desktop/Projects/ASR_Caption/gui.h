#ifndef GUI_H
#define GUI_H

#include <QWidget>
#include <QLabel>

class ASRCaption : public QWidget
{
    Q_OBJECT

public:
    ASRCaption(QWidget *parent = nullptr);
    ~ASRCaption();

public slots:
    void updateRecognitionResult(QString text);
    void setListeningState(bool listening);

private:
    QLabel *label;
};

#endif // GUI_H
