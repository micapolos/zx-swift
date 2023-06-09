import SwiftUI

struct ContentView: View {
  var body: some View {
    let ctx = CGContext(
      data: nil,
      width: Int(hLineSize),
      height: Int(vLineSize),
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
        let cycles = min(1_000_000, Int(Double(vFrameSize) * (timeInterval * 50)))
        NSLog("Cycles: %i", cycles)
        
        let videoMem = ctx.data!.bindMemory(to: UInt32.self, capacity: Int(vMemSize))
        
        let updateStartDate = Date.now
        _ = scrData.withUnsafeMutableBytes { zxPointer in
          romData.withUnsafeBytes { romPointer in
            zx.videoMem = videoMem
            zx.romMem = romPointer
            zx.scrMem = zxPointer
            zxUpdate(&zx, Int32(cycles))
          }
        }
        let updateEndDate = Date.now
        let utilization = 100.0 * updateEndDate.timeIntervalSince(updateStartDate) / timeInterval
        NSLog("Utilization: %.2f%%", utilization)
        let image = Image(ctx.makeImage()!, scale: 1, label: Text(verbatim: "dupa")).interpolation(.none)
        
        context.draw(image, in: CGRect(origin: .zero, size: size))
      }.aspectRatio(CGSize(width: CGFloat(hLineSize), height: CGFloat(vLineSize)), contentMode: ContentMode.fill)
    }
  }
}
