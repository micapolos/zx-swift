//
//  ContentView.swift
//  SwiftZx
//
//  Created by Misiu on 05/06/2023.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    let ctx = CGContext(
      data: nil,
      width: Zx.hLineSize,
      height: Zx.vLineSize,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    var zx = Zx()
    var lastDate: Date? = nil
    let romData = try! Data(contentsOf: Bundle.main.url(forResource: "Zx", withExtension: "rom")!)
    var scrData = try! Data(contentsOf: Bundle.main.url(forResource: "DynamiteDan", withExtension: "scr")!)
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        let timeInterval = timeline.date.timeIntervalSince(lastDate ?? timeline.date)
        NSLog("Interval: %f", timeInterval)
        lastDate = timeline.date
        let cycles = min(1_000_000, Int(Double(Zx.vFrameSize) * (timeInterval * 50)))
        NSLog("Cycles: %i", cycles)
        
        let videoMem = ctx.data!.bindMemory(to: UInt32.self, capacity: Zx.vMemSize)
        
        let updateStartDate = Date.now
        scrData.withUnsafeMutableBytes { zxPointer in
          romData.withUnsafeBytes { romPointer in
            zx.update(steps: cycles, videoMem: videoMem, romMem: romPointer, scrMem: zxPointer)
          }
        }
        let updateEndDate = Date.now
        NSLog("Update: %f", (updateEndDate.timeIntervalSince(updateStartDate)))
        let image = Image(ctx.makeImage()!, scale: 1, label: Text(verbatim: "dupa")).interpolation(.none)
        
        context.draw(image, in: CGRect(origin: .zero, size: size))
      }.aspectRatio(CGSize(width: Zx.hLineSize, height: Zx.vLineSize), contentMode: ContentMode.fill)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
