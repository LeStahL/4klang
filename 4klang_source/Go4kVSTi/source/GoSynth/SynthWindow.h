#pragma once

#include <QMainWindow>
#include <QWidget>

namespace Ui {
    class SynthWindow;
}

class SynthWindow : public QMainWindow {
    Q_OBJECT
    
    Ui::SynthWindow *_ui;

    public:
    SynthWindow();
    virtual ~SynthWindow();
};
