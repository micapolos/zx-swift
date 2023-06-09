#include "zx.h"

void zxUpdate(Zx* zxp, int steps) {
  struct Zx zx = *zxp;
  while (steps-- != 0) {
    int hScreenWrite = zx.hCounter >= hLeftBorderSize && zx.hCounter < hLeftBorderSize + hScreenSize;
    int vScreenWrite = zx.vCounter >= vTopBorderSize && zx.vCounter < vTopBorderSize + vScreenSize;
    int screenWrite = hScreenWrite && vScreenWrite;

    int hWrite = zx.hCounter < hLineSize;
    int vWrite = zx.vCounter < vLineSize;
    int memWrite = hWrite && vWrite;

    if (memWrite) {
      bool red, green, blue, bright;
      if (screenWrite) {
        int bit = zx.hCounter & 0x7;
        if (bit == 0) {
          int hAddr = ((zx.hCounter - hLeftBorderSize) >> 3) & 0x1f;
          int vAddr = zx.vCounter - vTopBorderSize;
          int pixelsAddr = (((vAddr & 0xC0) | ((vAddr & 0x7) << 3) | ((vAddr & 0x38) >> 3)) << 5) | hAddr;
          zx.pixels = zx.scrMem[pixelsAddr];
          int attrAddr = 0x1800 | ((vAddr >> 3) << 5) | hAddr;
          zx.attr = zx.scrMem[attrAddr];
        }

        bool pixelOn = (zx.pixels & 0x80) != 0;
        zx.pixels = zx.pixels << 1;

        bool flashOn = (zx.attr & 0x80) != 0;
        bool alternateOn = (zx.flashCounter & 0x10) != 0;

        bool inkOn = flashOn && alternateOn ? !pixelOn : pixelOn;
        red = (zx.attr & (inkOn ? 0x02 : 0x10)) != 0;
        green = (zx.attr & (inkOn ? 0x04 : 0x20)) != 0;
        blue = (zx.attr & (inkOn ? 0x01 : 0x08)) != 0;
        bright = (zx.attr & 0x40) != 0;
      } else {
        if (zx.barOn) {
          red = true;
          green = false;
          blue = false;
        } else {
          red = false;
          green = true;
          blue = true;
        }
        bright = false;
      }

      uint32_t component = bright ? 0xFF : 0xBB;

      uint32_t col = 0xFF000000 | (blue ? component << 16 : 0) | (green ? component << 8 : 0) | (red ? component : 0);

      zx.videoMem[zx.memAddr] = col;
      zx.memAddr = zx.memAddr + 1;
    }

    zx.hCounter++;
    if (zx.hCounter == hSize) {
      zx.hCounter = 0;
      zx.vCounter++;
      if (zx.vCounter == vSize) {
        zx.vCounter = 0;
        zx.memAddr = 0;
        zx.flashCounter++;
      }
    }

    zx.barCounter++;
    if (zx.barCounter == barSize) {
      zx.barCounter = 0;
      zx.barOn = !zx.barOn;
    }
  }
  *zxp = zx;
}
