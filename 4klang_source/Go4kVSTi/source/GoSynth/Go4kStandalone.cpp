#include <Windows.h>

#include <stdio.h>

#include "Go4kVSTiGUI.h"

void main() {
    LoadLibrary("4klang.dll");
    MSG msg;
    for(;;) {
        while(PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) {
			DispatchMessageA(&msg);
		}
    }
}
