#include <stdio.h>
#include "1602minidrv.h"


void main()
{
    _lcdStartup();
    _clearDisplay();
    _turnOnCursorOn();
    _setMemoryMode();

    _sendChar('1');
    _sendChar('2');
    _sendChar('3');

}
