#include "gui.h"
#include <QVBoxLayout>
#include <QScreen>
#include <QGuiApplication>
#include <QDebug>

ASRCaption::ASRCaption(QWidget *parent)
    : QWidget(parent)
{
    // Window settings: frameless, always on top, tool window (doesn't show in taskbar)
    setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Tool);
    // Make the window background transparent
    setAttribute(Qt::WA_TranslucentBackground);
    // Don't activate window when shown
    setAttribute(Qt::WA_ShowWithoutActivating, true);

    // Label settings
    label = new QLabel("Initializing...", this);
    label->setAlignment(Qt::AlignCenter);
    // A modern, clean look for the text
    label->setStyleSheet(
        "QLabel {"
        "  color: white;"
        "  background-color: rgba(0, 0, 0, 180);" // Semi-transparent black background
        "  font-family: 'Noto Sans';"
        "  font-size: 24px;"
        "  font-weight: bold;"
        "  padding: 15px;"
        "  border-radius: 10px;"
        "}"
    );

    // Layout
    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->addWidget(label);
    setLayout(layout);

    // Position the window at the bottom center of the primary screen
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        QRect screenGeometry = screen->geometry();
        int newWidth = screenGeometry.width() * 0.9; // 90% of screen width
        this->setFixedSize(newWidth, 100);
        int x = (screenGeometry.width() - this->width()) / 2;
        int y = screenGeometry.height() - this->height(); // Position at the very bottom
        this->move(x, y);
    }
}

ASRCaption::~ASRCaption()
{
}

void ASRCaption::updateRecognitionResult(QString text)
{
    if (text.isEmpty()) {
        label->setText("...");
    } else {
        label->setText(text);
    }
    // The size is fixed, so no need to adjust it dynamically.
}

void ASRCaption::setListeningState(bool listening)
{
    if (listening) {
        label->setText("Listening...");
    } else {
        // You might want to clear the text or show a "Done" message.
        // For now, we'll just let the result update handle it.
    }
}