#include "Go4kVSTiGUIQt.h"
#include "SynthWindow.h"

#include <QApplication>
#include <QDebug>

static char *argv[] = {
    {(char*)"4klang.dll"}
};
static int argc = 1;

void Go4kVSTiGUI_Show(int showCommand) {

}

void GetStreamFileName() {
    
}

DWORD WINAPI appThread(LPVOID params) {
    QApplication a(argc, argv);
    SynthWindow d;
    d.show();
    a.exec();
}

static HANDLE hThread;
void Go4kVSTiGUI_Create(HINSTANCE hInst) {
    hThread = CreateThread(0, 0, appThread, 0, 0, 0);
}

void Go4kVSTiGUI_Destroy(void) {
    TerminateThread(hThread, 0);
}
