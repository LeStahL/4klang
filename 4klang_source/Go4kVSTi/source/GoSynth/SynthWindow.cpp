#include "SynthWindow.h"
#include "ui_synthwindow.h"

#include "Windows.h"

#include <QDebug>

SynthWindow::SynthWindow()
    : QMainWindow()
    , _ui(new Ui::SynthWindow)
    , _settings(new QSettings("Alcatraz", "4klang"))
{
    _ui->setupUi(this);

    // Recent items
    _recentFilenames = _settings->value("recents").toStringList();
    for(int i=0; i<_recentFilenames.size(); ++i) {
        QAction *recentAction = new QAction(_recentFilenames.at(i));
        QObject::connect(recentAction, &QAction::triggered, this, [this, i]{this->openRecent(i);});
        _ui->menuOpen_Recent->addAction(recentAction);
        _recentFilenameActions.push_back(recentAction);
    }

    QObject::connect(this, &SynthWindow::destroyed, this, &SynthWindow::close);
    QObject::connect(_ui->actionNew, &QAction::triggered, this, &SynthWindow::newPatch);
}

SynthWindow::~SynthWindow()
{
    delete _ui;
    delete _settings;
}

void SynthWindow::close() {
    ExitProcess(0);
}

void SynthWindow::openPatch() {

}

void SynthWindow::_openFileWithName(QString filename) {

}

void SynthWindow::openRecent(int index) {
    qDebug() << "opening recent:" << index <<  _recentFilenames.at(index);
    _openFileWithName(_recentFilenames.at(index));   
}

void SynthWindow::newPatch() {

}
