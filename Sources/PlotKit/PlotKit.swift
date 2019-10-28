import CoreGraphics

public func plot(x: [CGFloat], y: [CGFloat]) {
    
    let size = CGSize(width: 75, height: 75)
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
    
    let sx: CGFloat
    let sy: CGFloat
    let tx: CGFloat
    let ty: CGFloat
    if let xmin = x.min(), let xmax = x.max() {
        sx = (xmax - xmin)*size.width
        tx = 0
    } else {
        sx = 1
        tx = 0
    }
    if let ymin = y.min(), let ymax = y.max() {
        sy = (ymax - ymin)/size.height
        ty = 0
    } else {
        sy = 1
        ty = 0
    }
    
    print(bitmapContext?.convertToDeviceSpace(points[0]))
    print(bitmapContext?.ctm)
    print(bitmapContext?.userSpaceToDeviceSpaceTransform)
    bitmapContext?.scaleBy(x: sx, y: sy)
    bitmapContext?.translateBy(x: tx, y: ty)
    
    print(points[0])
    print(bitmapContext?.convertToDeviceSpace(points[0]))
    print(bitmapContext?.ctm)
    print(bitmapContext?.userSpaceToDeviceSpaceTransform)
}
