#pragma once
#include <windows.h>
//extern "C" int _stdcall InsertionSort(int arr[], int n);
extern "C" int _stdcall ReadTime(void);
typedef void(_fastcall* InsertionSort)(float*, unsigned char*, int, int); //asemblerowa funkcja z dll