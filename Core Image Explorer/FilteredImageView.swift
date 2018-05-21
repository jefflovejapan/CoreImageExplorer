//
//  FilteredImageView.swift
//  Core Image Explorer
//
//  Created by Warren Moore on 1/8/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import GLKit
import OpenGLES

class FilteredImageView: GLKView, ParameterAdjustmentDelegate {

    var ciContext: CIContext!

    var filter: CIFilter! {
        didSet {
            setNeedsDisplay()
        }
    }

    var inputImage: UIImage! {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame, context: EAGLContext(api: .openGLES2)!)    // initializing view with an EAGLContext (the view is bound to the context?)
        clipsToBounds = true
        ciContext = CIContext(eaglContext: context) // creating a CIContext backed by same EAGLContext. Drawing into this ciContext draws into the view?
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        self.context = EAGLContext(api: .openGLES2)!    // had no idea that the view's context was settable
        ciContext = CIContext(eaglContext: context)
    }

    override func draw(_ rect: CGRect) {
        guard ciContext != nil && inputImage != nil && filter != nil else {
            return
        }
        let inputCIImage = CIImage(image: inputImage)
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else {
            return
        }
        clearBackground()

        let inputBounds = inputCIImage!.extent
        let drawableBounds = CGRect(x: 0, y: 0, width: self.drawableWidth, height: self.drawableHeight)
        let targetBounds = imageBoundsForContentMode(fromRect: inputBounds, toRect: drawableBounds)
        ciContext.draw(outputImage, in: targetBounds, from: inputBounds)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }

    func clearBackground() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }

    func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;

        var fitRect = toRect

        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        }

        return fitRect.integral
    }

    func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;

        var fitRect = toRect

        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        }

        return fitRect.integral
    }

    func imageBoundsForContentMode(fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFill:
            return aspectFill(fromRect: fromRect, toRect: toRect)
        case .scaleAspectFit:
            return aspectFit(fromRect: fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }

    func parameterValueDidChange(param parameter: ScalarFilterParameter) {
        filter.setValue(parameter.currentValue, forKey: parameter.key)
        setNeedsDisplay()
    }
}
