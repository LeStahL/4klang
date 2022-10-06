#include <Windows.h>

#include <stdio.h>

#ifdef USE_QT
#include "Go4kVSTiGUIQt.h"
#else
#include "Go4kVSTiGUI.h"
#endif

void main() {
    LoadLibrary("4klang.dll");
    MSG msg;
    for(;;) {
        while(PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) {
			DispatchMessageA(&msg);
		}
    }
}
