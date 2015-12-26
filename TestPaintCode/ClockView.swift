//
//  ClockView.swift
//  TestPaintCode
//
//  Created by Mark Broski on 12/22/15.
//  Copyright © 2015 Mark Broski. All rights reserved.
//

import Foundation
import UIKit


typealias UpdatePropertyBlock = (CGFloat) -> Void
typealias UpdatePropertyCompletionBlock = (Bool) -> Void

enum AnimationTiming {
    case Linear
    case SmoothStep
    case SmootherStep
}


class PropertyAnimator: NSObject {
    private var startTime: CFTimeInterval!
    private var endTime: CFTimeInterval!
    private var duration: CFTimeInterval!
    private var startValue: CGFloat!
    private var endValue: CGFloat!
    private var updatePropertyBlock: UpdatePropertyBlock!
    private var updatePropertyCompletionBlock: UpdatePropertyCompletionBlock?
    private var animationTiming: AnimationTiming!

    func animatePropertyFrom(startValue: CGFloat, to endValue: CGFloat, duration: CFTimeInterval, animationTiming: AnimationTiming, updatePropertyBlock: UpdatePropertyBlock, completionBlock: UpdatePropertyCompletionBlock? = nil) {
        self.startValue = startValue
        self.endValue = endValue
        startTime = CACurrentMediaTime()
        self.duration = duration
        self.endTime = startTime + duration
        self.animationTiming = animationTiming
        self.updatePropertyBlock = updatePropertyBlock
        self.updatePropertyCompletionBlock = completionBlock
        start()
    }

    /// calculates the percentage complete for the animation, using the SmoothStep Alogrithm (http://sol.gfxile.net/interpolation/#s4)
    func calculatePercentComplete() -> CGFloat {
        let elapsedTime = CACurrentMediaTime() - startTime
        let percentComplete = elapsedTime / duration
        let smoothedPercentComplete = percentComplete * percentComplete * (3 - (2 * percentComplete))
        return CGFloat(smoothedPercentComplete)
    }

    func setValueForCompletionPercentage(completionPercent: CGFloat) {
        let newValue: CGFloat = startValue * (1.0 - completionPercent) + (endValue * completionPercent)
        updatePropertyBlock(newValue)
    }

    // you could overwrite this too
    func handleTimer(displayLink: CADisplayLink) {
        if displayLink.timestamp > endTime {
            setValueForCompletionPercentage(1)
            runCompletionBlock(true)
            stop(displayLink)
        } else {
            setValueForCompletionPercentage(calculatePercentComplete())
        }

    }

    func start() {
        let displayLink = CADisplayLink(target: self, selector: Selector("handleTimer:"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }

    func stop(displayLink: CADisplayLink) {
        displayLink.invalidate()
        updatePropertyBlock = nil
    }

    func runCompletionBlock(finished: Bool) {
        if let completionBlock = updatePropertyCompletionBlock {
            completionBlock(finished)
        }
    }

}

@IBDesignable
class ClockView: UIView {
    var circlePadding: CGFloat = 100
    var strokeWidth: CGFloat = 1
    override dynamic func drawRect(rect: CGRect) {
        StyleKitName.drawCanvas1(frameValue: self.bounds, circlePadding: circlePadding, strokeWidth: strokeWidth)
    }

    func updateCirclePadding(newCirclePadding: CGFloat) {
        let animator = PropertyAnimator()
        let updateBlock: UpdatePropertyBlock = {
            [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.circlePadding = value
            strongSelf.setNeedsDisplay()
        }

        let completionBlock: UpdatePropertyCompletionBlock = {
            [weak self] finished in
            guard let strongSelf = self else {
                return
            }
            strongSelf.updateStrokeWidth(10)
        }


        animator.animatePropertyFrom(self.circlePadding, to: newCirclePadding, duration: 0.3, animationTiming: .SmoothStep, updatePropertyBlock: updateBlock, completionBlock: completionBlock)
    }

    func updateStrokeWidth(newStrokeWidth: CGFloat) {
        let animator = PropertyAnimator()
        let updateBlock: UpdatePropertyBlock = {
            [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.strokeWidth = value
            strongSelf.setNeedsDisplay()

        }
        animator.animatePropertyFrom(self.strokeWidth, to: newStrokeWidth, duration: 0.3, animationTiming: .SmoothStep, updatePropertyBlock: updateBlock)
    }


}
