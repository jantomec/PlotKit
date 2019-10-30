import Foundation
import CoreGraphics
import CoreText

/// Plot data with two lists of x and y values.
///
/// This function takes in two lists of values which combined represents points to be drawn. Also take a look at `PKPlotOptions` to see how to adapt image ouput.
///
/// Usage:
///
///     let x: [CGFloat] = linspace(from: 0, to: 10, n: 31)
///     let y = x.map { pow($0, 2) }
///
///     let opts: [PKPlotOption : Any] = [
///         .connected : true,
///         .ylimit : (CGFloat(0), CGFloat(120))
///     ]
///
///     let graph = plot(x: x, y: y, size: imageView!.frame.size, options: opts)
/// - Parameter x: Values on abscissa
/// - Parameter y: Values on ordinate
/// - Parameter size: Size of image created
/// - Parameter options: Additional options for personalizing output image
/// - Returns: Image of plot as CGImage optional
public func plot(x: [CGFloat], y: [CGFloat], size: CGSize,
                 options: [PKPlotOption : Any] = [:]) -> CGImage? {
    
    var bitmapContext = createCGContext(size: size)
    
    pkplot(x: x, y: y, size: size, options: options, bitmapContext: &bitmapContext)
    
    return bitmapContext.makeImage()
    
}

/// Plot multiple sets of data.
///
/// This function can plot multiple sets of data. Each set of data will be plotted in the similar manner as if it was an individual input, however all plots share same coordinate system.
///
/// Usage:
///
///     let x: [[CGFloat]] = [linspace(from: 0, to: 10, n: 31), linspace(from: 5, to: 15, n: 31)]
///     let y0 = x[0].map { pow($0, 2) }
///     let y1 = x[0].map { pow($0, -1) }
///
///     let opts: [PKPlotOption : Any] = [
///         .connected : true,
///         .ylimit : (CGFloat(0), CGFloat(120))
///     ]
///
///     let graph = plot(x: x, y: [y0, y1], size: imageView!.frame.size, options: opts)
/// - Parameter x: Values on abscissa
/// - Parameter y: Values on ordinate
/// - Parameter size: Size of image created
/// - Parameter options: Additional options for personalizing output image
/// - Returns: Image of plot as CGImage optional
public func plot(x: [[CGFloat]], y: [[CGFloat]], size: CGSize,
                 options: [PKPlotOption : Any] = [:]) -> CGImage? {
    
    var bitmapContext = createCGContext(size: size)
    
    let xdataRange = (x.flatMap({ $0 }).min() ?? 0, x.flatMap({ $0 }).max() ?? 1)
    let ydataRange = (y.flatMap({ $0 }).min() ?? 0, y.flatMap({ $0 }).max() ?? 1)
    
    var opts = options
    if opts[.xlimit] == nil {
        opts[.xlimit] = xdataRange
    }
    if opts[.ylimit] == nil {
        opts[.ylimit] = ydataRange
    }
    
    let n = x.count
    
    for i in 0..<n {
        if i == 0 {
            pkplot(x: x[i], y: y[i], size: size, options: opts, bitmapContext: &bitmapContext)
        } else {
            pkplot(x: x[i], y: y[i], size: size, showAxes: false, options: opts, bitmapContext: &bitmapContext)
        }
    }
    
    return bitmapContext.makeImage()
    
}

func pkplot(x: [CGFloat], y: [CGFloat], size: CGSize, showAxes: Bool = true,
          options: [PKPlotOption : Any] = [:], bitmapContext: inout CGContext) {
    
    // PREFERENCES - colors, fonts, ...
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let annotationColor = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 1])!
    let plotColor = CGColor(colorSpace: colorSpace, components: [0.8, 0.4, 0.2, 1])!
    let fontAttributes = [
        kCTFontFamilyNameAttribute : "Arial",
//        kCTFontStyleNameAttribute : "Bold",
        kCTFontSizeAttribute : 18.0
    ] as NSDictionary
    
    let descriptor = CTFontDescriptorCreateWithAttributes(fontAttributes)
    let font = CTFontCreateWithFontDescriptor(descriptor, 0.0, nil)
    let attributes = [kCTFontAttributeName : font] as CFDictionary
    
    // ANNOTATIONS - labels, legends, ticks...
    
    let (xticks, yticks) = ticks(dataX: x, y: y,
                                 xlimit: options[.xlimit] as? (CGFloat, CGFloat),
                                 ylimit: options[.ylimit] as? (CGFloat, CGFloat))
    
    let tallestXtickLabel: CGFloat
    let widestYtickLabel: CGFloat
    tallestXtickLabel = xticks.map({
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        return labelSize.height
    }).max() ?? 0
    widestYtickLabel = yticks.map({
        let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                  $0.description as NSString,
                                                  attributes)
        let textLine = CTLineCreateWithAttributedString(attrString!)
        let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
        return labelSize.width
    }).max() ?? 0
    
    // TRANSFORMATION OF COORDINATES
    
    let transform = fitTransform(dataX: x, y: y,
                                 size: size,
                                 padding: CGVector(dx: widestYtickLabel, dy: tallestXtickLabel),
                                 xlimit: options[.xlimit] as? (CGFloat, CGFloat),
                                 ylimit: options[.ylimit] as? (CGFloat, CGFloat))
    
    // AXES
    
    bitmapContext.setFillColor(annotationColor)
    bitmapContext.setStrokeColor(annotationColor)
    
    if showAxes {
    
        let origin = CGPoint.zero.applying(transform)
        
        bitmapContext.beginPath()
        
        bitmapContext.move(to: CGPoint(x: 0, y: origin.y))  // x axis
        bitmapContext.addLine(to: CGPoint(x: size.width, y: origin.y))
        bitmapContext.move(to: CGPoint(x: origin.x, y: 0))
        bitmapContext.addLine(to: CGPoint(x: origin.x, y: size.height))  // y axis
        bitmapContext.strokePath()
        
        xticks.dropFirst().forEach {
            // tick
            bitmapContext.move(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x,
                                           y: origin.y))
            bitmapContext.addLine(to: CGPoint(x: CGPoint(x: $0, y: 0).applying(transform).x,
                                              y: origin.y+6))
            bitmapContext.strokePath()
            // tick label
            let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                      $0.description as NSString,
                                                      attributes)
            let textLine = CTLineCreateWithAttributedString(attrString!)
            let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
            bitmapContext.textPosition = CGPoint(
                x: CGPoint(x: $0, y: 0).applying(transform).x - labelSize.width/2,
                y: origin.y - labelSize.height-4
            )
            CTLineDraw(textLine, bitmapContext)
            
        }
        yticks.dropFirst().forEach {
            // tick
            bitmapContext.move(to: CGPoint(x: origin.x,
                                           y: CGPoint(x: 0, y: $0).applying(transform).y))
            bitmapContext.addLine(to: CGPoint(x: origin.x+6,
                                              y: CGPoint(x: 0, y: $0).applying(transform).y))
            bitmapContext.strokePath()
            // tick label
            let attrString = CFAttributedStringCreate(kCFAllocatorDefault,
                                                      $0.description as NSString,
                                                      attributes)
            let textLine = CTLineCreateWithAttributedString(attrString!)
            let labelSize = CTLineGetImageBounds(textLine, bitmapContext)
            bitmapContext.textPosition = CGPoint(
                x: origin.x - labelSize.width-4,
                y: CGPoint(x: 0, y: $0).applying(transform).y - labelSize.height/2
            )
            CTLineDraw(textLine, bitmapContext)
            
        }
        
    }
    
    // DRAW POINTS
    
    let points = x.indices.map { CGPoint(x: x[$0], y: y[$0]) }
    
    bitmapContext.setFillColor(plotColor)
    bitmapContext.setStrokeColor(plotColor)
    bitmapContext.setLineWidth(2) // default is 1
    
    if let connected = options[.connected] as? Bool {
        if connected {
            points.dropLast().indices.forEach {
                (i) in
                bitmapContext.beginPath()
                bitmapContext.move(to: points[i].applying(transform))
                bitmapContext.addLine(to: points[i+1].applying(transform))
                bitmapContext.strokePath()
            }
        }
    }
    points.forEach {
        (p) in
        bitmapContext.beginPath()
        bitmapContext.addArc(center: p.applying(transform), radius: 3, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        bitmapContext.closePath()
        bitmapContext.drawPath(using: .eoFillStroke)
    }
    
}
