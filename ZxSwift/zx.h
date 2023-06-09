#ifndef zx_h
#define zx_h

#include <stdio.h>
#include <stdbool.h>

static const int hLeftBorderSize = 48;
static const int hScreenSize = 256;
static const int hRightBorderSize = 48;
static const int hBlankSize = 96;

static const int vTopBorderSize = 48;
static const int vScreenSize = 192;
static const int vBottomBorderSize = 48;
static const int vBlankSize = 24;

static const int hLineSize = hLeftBorderSize + hScreenSize + hRightBorderSize;
static const int vLineSize = vTopBorderSize + vScreenSize + vBottomBorderSize;
static const int vMemSize = hLineSize * vLineSize;

static const int hSize = hLineSize + hBlankSize;
static const int vSize = vLineSize + vBlankSize;
static const int vFrameSize = hSize * vSize;

static const int barSize = vFrameSize / 28 - 43;

typedef struct Reg {
  int pc, sp;
  int lhs, rhs;
  int a, f;
  int a2, f2;
  int wz, bc, de, hl;
  int wz2, bc2, de2, hl2;
  int ix, iy;
  int i, r;
  int op;
} Reg;

typedef struct Zx {
  int vCounter;
  int hCounter;
  
  int barCounter;
  bool barOn;
  
  int memAddr;
  
  int attr;
  int pixels;
  
  int frameCounter;
  
  Reg reg;
  
  uint32_t* videoMem;
  uint8_t const* romMem;
  uint8_t* scrMem;
} Zx;

void zxUpdate(Zx* zx, int steps);

#endif /* zx_h */
