#include "SynthWindow.h"
#include "ui_synthwindow.h"

SynthWindow::SynthWindow()
    : QMainWindow()
    , _ui(new Ui::SynthWindow)
{
    _ui->setupUi(this);
}

SynthWindow::~SynthWindow()
{
    delete _ui;
}
