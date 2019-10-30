# PlotKit

Swift package for ploting. Works on MacOS and on iOS. Main function plot creates a CGImage that can be used then as the data source for UIImage.

Demo:

```swift
let x: [[CGFloat]] = [linspace(from: 0, to: 10, n: 31), linspace(from: 5, to: 15, n: 31)]
let y0 = x[0].map { pow($0, 2) }
let y1 = x[1].map { 90-400*pow($0, -1) }
        
let opts: [PKPlotOption : Any] = [
    .connected : true,
    .xlimit : (CGFloat(0), CGFloat(18))
]
        
let graph = plot(x: x, y: [y0, y1], size: imageView!.frame.size, options: opts)
        
imageView.image = UIImage(cgImage: graph!)
```

<p align="center">
  <img src="https://i.imgur.com/akUNfxe.png" width="300" title="Demo">
</p>
