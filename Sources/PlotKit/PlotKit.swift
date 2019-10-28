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
        sx = 0.9*size.width*(xmax - xmin)
        tx = 0.05*size.width*(xmax - xmin)
    } else {
        sx = 0.9
        tx = 0.05
    }
    if let ymin = y.min(), let ymax = y.max() {
        sy = 0.9*size.height*(ymax - ymin)
        ty = 0.05*size.height*(ymax - ymin)
    } else {
        sy = 0.9
        ty = 0.05
    }
    
    bitmapContext?.scaleBy(x: sx, y: sy)
    bitmapContext?.translateBy(x: tx, y: ty)
    
    print(bitmapContext?.convertToDeviceSpace(points[0]))
    print(bitmapContext?.ctm)
    
}
