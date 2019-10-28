import CoreGraphics

public func plot<T: Numeric>(x: [T], y: [T]) {
    
    let size = CGSize(width: 100, height: 100)
    let bitsPerComponent = 8
    let bytesPerRow = 0
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapContext = CGContext(data: nil,
                                  width: Int(size.width),
                                  height: Int(size.height),
                                  bitsPerComponent: Int(bitsPerComponent),
                                  bytesPerRow: Int(bytesPerRow),
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
}
