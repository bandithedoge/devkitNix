#include <gccore.h>
#include <malloc.h>
#include <ogcsys.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef NIX_VERSION
#define NIX_VERSION "Nix version unknown"
#endif

static void *xfb = NULL;
static GXRModeObj *rmode = NULL;

void *Initialise();

int main(int argc, char **argv) {

  xfb = Initialise();

  printf("\nI was compiled with devkitNix using %s!\n", NIX_VERSION);

  while (1) {

    VIDEO_WaitVSync();
    PAD_ScanPads();

    int buttonsDown = PAD_ButtonsDown(0);

    if (buttonsDown & PAD_BUTTON_A) {
      printf("Button A pressed.\n");
    }

    if (buttonsDown & PAD_BUTTON_START) {
      exit(0);
    }
  }

  return 0;
}

void *Initialise() {

  void *framebuffer;

  VIDEO_Init();
  PAD_Init();

  rmode = VIDEO_GetPreferredMode(NULL);

  framebuffer = MEM_K0_TO_K1(SYS_AllocateFramebuffer(rmode));
  console_init(framebuffer, 20, 20, rmode->fbWidth, rmode->xfbHeight,
               rmode->fbWidth * VI_DISPLAY_PIX_SZ);

  VIDEO_Configure(rmode);
  VIDEO_SetNextFramebuffer(framebuffer);
  VIDEO_SetBlack(FALSE);
  VIDEO_Flush();
  VIDEO_WaitVSync();
  if (rmode->viTVMode & VI_NON_INTERLACE)
    VIDEO_WaitVSync();

  return framebuffer;
}
