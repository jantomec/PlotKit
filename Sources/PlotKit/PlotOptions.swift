//
//  PlotOptions.swift
//  
//
//  Created by Jan Tomec on 30/10/2019.
//


/// Plot options for plot function
///
/// Plot options are used in a dictionary:
///
/// `[PKPlotOption : Any]`,
///
///  which is argument for `plot` function.
public enum PKPlotOption {
    /// Choose whether the plot points should be connected with straight lines.
    ///
    /// Defined value should be of type `Bool`. Default value is `false`.
    ///
    /// Usage:
    ///
    ///     let options: [PKPlotOptions : Any] = [connected : false]
    case connected
    
    /// Set the range on x axis.
    ///
    /// Defined value should be of type `(CGFloat, CGFloat)`. If left undefined, `plot` function automatically tries to set correct range by inspecting input data.
    ///
    /// Usage:
    ///
    ///     let options: [PKPlotOptions : Any] = [xlimit : (CGFloat(0), CGFloat(10))]
    case xlimit
    
    /// Set the range on y axis.
    ///
    /// Defined value should be of type `(CGFloat, CGFloat)`. If left undefined, `plot` function automatically tries to set correct range by inspecting input data.
    ///
    /// Usage:
    ///
    ///     let options: [PKPlotOptions : Any] = [ylimit : (CGFloat(0), CGFloat(10))]
    case ylimit
}
