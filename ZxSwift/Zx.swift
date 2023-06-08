import Foundation

struct Zx {
  static let hLeftBorderSize = 48
  static let hScreenSize = 256
  static let hRightBorderSize = 48
  static let hBlankSize = 96
  
  static let vTopBorderSize = 48
  static let vScreenSize = 192
  static let vBottomBorderSize = 48
  static let vBlankSize = 24
  
  static let hLineSize = hLeftBorderSize + hScreenSize + hRightBorderSize
  static let vLineSize = vTopBorderSize + vScreenSize + vBottomBorderSize
  static let vMemSize = hLineSize * vLineSize
  
  static let hSize = hLineSize + hBlankSize
  static let vSize = vLineSize + vBlankSize
  static let vFrameSize = hSize * vSize
  
  static let barSize = vFrameSize / 28 - 43
  
  var vCounter: UInt16 = 0
  var hCounter: UInt16 = 0
  
  var barCounter: UInt16 = 0
  var barOn = false
  
  var memAddr : Int = 0
  
  var attr: UInt8 = 0
  var pixels: UInt8 = 0
  
  var flashCounter: UInt8 = 0
  
  var reg = Reg()
}

struct Reg {
  var pc: UInt16 = 0
  var sp: UInt16 = 0
  var lhs: UInt8 = 0
  var rhs: UInt8 = 0
  var a: UInt8 = 0
  var f: UInt8 = 0
  var a2: UInt8 = 0
  var f2: UInt8 = 0
  var wz: UInt16 = 0
  var bc: UInt16 = 0
  var de: UInt16 = 0
  var hl: UInt16 = 0
  var wz2: UInt16 = 0
  var bc2: UInt16 = 0
  var de2: UInt16 = 0
  var hl2: UInt16 = 0
  var ix: UInt16 = 0
  var iy: UInt16 = 0
  var i: UInt8 = 0
  var r: UInt8 = 0
  var op: UInt8 = 0
}

extension Zx {
  mutating func update(steps: Int, videoMem: UnsafeMutablePointer<UInt32>, romMem: UnsafePointer<UInt8>, scrMem: UnsafeMutablePointer<UInt8>) {
    for _ in 0..<steps {
      let hScreenWrite = hCounter >= Zx.hLeftBorderSize && hCounter < Zx.hLeftBorderSize &+ Zx.hScreenSize
      let vScreenWrite = vCounter >= Zx.vTopBorderSize && vCounter < Zx.vTopBorderSize &+ Zx.vScreenSize
      let screenWrite = hScreenWrite && vScreenWrite

      let hWrite = hCounter < Zx.hLineSize
      let vWrite = vCounter < Zx.vLineSize
      let memWrite = hWrite && vWrite

      if (memWrite) {
        let red, green, blue, bright: Bool
        if (screenWrite) {
          let bit = hCounter & 0x7
          if (bit == 0) {
            let hAddr = ((Int(hCounter) - Zx.hLeftBorderSize) >> 3) & 0x1f
            let vAddr = (Int(vCounter) - Zx.vTopBorderSize)
            let pixelsAddr = (((vAddr & 0xC0) | ((vAddr & 0x7) << 3) | ((vAddr & 0x38) >> 3)) << 5) | hAddr
            pixels = scrMem[pixelsAddr]
            let attrAddr = 0x1800 | ((vAddr >> 3) << 5) | hAddr
            attr = scrMem[attrAddr]
          }

          let pixelOn = (pixels & 0x80) != 0
          pixels = pixels << 1

          let flashOn = (attr & 0x80) != 0
          let alternateOn = flashCounter & 0x10 != 0
          
          let inkOn = flashOn && alternateOn ? !pixelOn : pixelOn
          red = attr & (inkOn ? 0x02 : 0x10) != 0
          green = attr & (inkOn ? 0x04 : 0x20) != 0
          blue = attr & (inkOn ? 0x01 : 0x08) != 0
          bright = (attr & 0x40) != 0
        } else {
          if (barOn) {
            red = true
            green = false
            blue = false
          } else {
            red = false
            green = true
            blue = true
          }
          bright = false
        }
        
        let component: UInt32 = bright ? 0xFF : 0xBB
        
        let col: UInt32 = 0xFF000000 | (blue ? component << 16 : 0) | (green ? component << 8 : 0) | (red ? component : 0)
        
        videoMem[memAddr] = col
        memAddr = memAddr &+ 1
      }

      hCounter = hCounter &+ 1
      if (hCounter == Zx.hSize) {
        hCounter = 0
        vCounter = vCounter &+ 1
        if (vCounter == Zx.vSize) {
          vCounter = 0
          memAddr = 0
          flashCounter = flashCounter &+ 1
        }
      }
      
      barCounter = barCounter &+ 1
      if (barCounter == Zx.barSize) {
        barCounter = 0
        barOn = !barOn
      }
    }
  }
}
