/*---------------------------------------------------------------------------------

        $Id: main.cpp,v 1.13 2008-12-02 20:21:20 dovoto Exp $

        Simple console print demo
        -- dovoto


---------------------------------------------------------------------------------*/
#include <nds.h>

#include <stdio.h>

#ifndef NIX_VERSION
#define NIX_VERSION "Nix version unknown"
#endif

volatile int frame = 0;

//---------------------------------------------------------------------------------
void Vblank() {
  //---------------------------------------------------------------------------------
  frame++;
}

//---------------------------------------------------------------------------------
int main(void) {
  //---------------------------------------------------------------------------------
  touchPosition touchXY;

  irqSet(IRQ_VBLANK, Vblank);

  consoleDemoInit();

  iprintf("I was compiled with devkitNix\n");
  iprintf("using %s!", NIX_VERSION);

  while (1) {

    swiWaitForVBlank();
    scanKeys();
    int keys = keysDown();
    if (keys & KEY_START)
      break;

    touchRead(&touchXY);

    // print at using ansi escape sequence \x1b[line;columnH
    iprintf("\x1b[10;0HFrame = %d", frame);
    iprintf("\x1b[16;0HTouch x = %04X, %04X\n", touchXY.rawx, touchXY.px);
    iprintf("Touch y = %04X, %04X\n", touchXY.rawy, touchXY.py);
  }

  return 0;
}
