#pragma once

#include <QMainWindow>
#include <QWidget>
#include <QSettings>
#include <QStringList>
#include <QList>
#include <QAction>

namespace Ui {
    class SynthWindow;
}

class SynthWindow : public QMainWindow {
    Q_OBJECT

    Ui::SynthWindow *_ui;
    QSettings *_settings;
    QStringList _recentFilenames;
    QList<QAction *> _recentFilenameActions;

    void _openFileWithName(QString filename);

    private slots:
    void close();
    void openPatch();
    void openRecent(int index);
    void newPatch();

    public:
    SynthWindow();
    virtual ~SynthWindow();
};
