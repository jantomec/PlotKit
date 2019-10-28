import CoreGraphics

public func plot(x: [Double], y: [Double]) {
    
    let size = CGSize(width: 100, height: 100)
    let bitsPerComponent = 8
    let bytesPerRow = 0 // 0 means automatic calculation if data == nil
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapContext = CGContext(data: nil,
                                  width: Int(size.width),
                                  height: Int(size.height),
                                  bitsPerComponent: Int(bitsPerComponent),
                                  bytesPerRow: Int(bytesPerRow),
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    let points = x.indices.map { CGPoint(x: x[$0], y: y[$0]) }
    print(points)
    
    print(bitmapContext?.convertToUserSpace(points[0]))
    
}
