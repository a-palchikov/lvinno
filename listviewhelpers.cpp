
#include <windows.h>
#include <commctrl.h>

#pragma comment(linker, "/EXPORT:CopyPtrValue=_CopyPtrValue@12")

extern "C" {
    void __stdcall CopyPtrValue(LPVOID ptr, DWORD cbSize, LPVOID pValue)
    {
        memcpy(pValue, ptr, cbSize);
    }
} // extern "C"
