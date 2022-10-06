#pragma once

#include <QMainWindow>
#include <QWidget>

namespace Ui {
    class SynthWindow;
}

class SynthWindow : public QMainWindow {
    Ui::SynthWindow *_ui;

    public:
    SynthWindow();
    virtual ~SynthWindow();
};
