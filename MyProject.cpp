#include <iostream>
#include <Windows.h>
#include "MyProject.h"
#include <chrono>

using namespace std;
using namespace std::chrono;


void insertionSortcpp(int arr[], int n)
{
    int i, key, j;
    for (i = 1; i < n; i++)
    {
        key = arr[i];
        j = i - 1;

       
        while (j >= 0 && arr[j] > key)
        {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
        
    }
    
    
}




int main(int argc, char* argv[])
{
    HINSTANCE dllHandle = NULL;
    dllHandle = LoadLibrary(L"MojaDll.dll");
    int number;
    const int n = 20;
    int arr[n];

    cout << "Enter 10 number you want to sort" << endl;
    for (int i = 0; i < 20; i++)
    {
        cout << "Enter the number: " << endl;
        cin >> number;
        arr[i] = number;
    }
    cout << "Your array looks as follows: " << endl;
    for (int i = 0; i < 20; i++)
    {
        cout << arr[i] << ", ";
    }
    
    string choice;
    cout << "Write 'asm' to run the assembly code or 'c++' to run the c++ code" << endl;
    cin >> choice;
    if (choice == "asm")
    {
        auto start = high_resolution_clock::now();
        cout << "The result of insertion sort done by asm code" << endl;
        void(*funkcja)(int*, int);
        funkcja = (void(*)(int*, int))GetProcAddress(dllHandle, "InsertionSort");
        funkcja(arr, 20);
        auto stop = high_resolution_clock::now();
        auto duration = duration_cast<microseconds>(stop - start);
        cout << "Time taken by function: "
            << duration.count() << " microseconds" << endl;
        for (int i = 0; i < n; i++)
            cout << arr[i] << ", ";
    }
    else if (choice == "c++")
    {
        auto start = high_resolution_clock::now();
        cout << "The result of insertion sort done by c++ code" << endl;
        insertionSortcpp(arr, 20);
        auto stop = high_resolution_clock::now();
        auto duration = duration_cast<microseconds>(stop - start);
        cout << "Time taken by function: "
            << duration.count() << " microseconds" << endl;
        for (int i = 0; i < n; i++)
            cout << arr[i] << " ";
    }
    else
    {
        cout << "Wrong format!" << endl;
    }

    cout << "Do you want to continue? yes/no" << endl;
    string choice2;
    cin >> choice2;
    if (choice2 == "yes")
    {
        main(argc, argv);

    }
    else 
    return 0;
}