//
//  BallView.swift
//  UIDynamicsDemoSwift
//
//  Created by xiwang wang on 2017/9/11.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

import UIKit

class BallView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.yellow
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class NewtonsCradleView: UIView {
    
    //
    var ballCount: Int = 0
    
    //球和锚点
    var _balls: Array<BallView> = []
    var _archors: Array<UIView> = []
    
    var _animator: UIDynamicAnimator!
    var _userDragBehavior: UIPushBehavior?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ballCount = 5
        createBallsAndAnchors()
        applyDynamicBehaviors()
    }
    
    //MARK: - 创建球及锚点
    func createBallsAndAnchors() {
        let ballSize: CGFloat = (self.bounds.width) / (3.0*CGFloat((ballCount - 1)))
        for i in 0...ballCount - 1 {
            let ball: BallView = BallView.init(frame: CGRect(x: 0, y: 0, width: ballSize - 1, height: ballSize - 1))
            let x: CGFloat = self.bounds.width / 3.0 + CGFloat(i)*ballSize
            let y: CGFloat = self.bounds.height / 1.5
            ball.center = CGPoint(x: x, y: y)
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleBallPan(panGesture:)))
            ball.addGestureRecognizer(panGesture)
            ball.addObserver(self, forKeyPath: "center", options: NSKeyValueObservingOptions.new, context: nil)
            _balls.append(ball)
            self.addSubview(ball)
            
            let blueBox: UIView = createAnchorForBall(ball: ball)
            _archors.append(blueBox)
            self.addSubview(blueBox)
        }
        
    }
    
    //MARK: - 处理手势事件
    func handleBallPan(panGesture: UIPanGestureRecognizer) {
        //用户开始拖动时创建一个新的UIPushBehavior,并添加到animator中
        if panGesture.state == UIGestureRecognizerState.began {
            if let _ = _userDragBehavior {
                _animator.removeBehavior(_userDragBehavior!)
            }
            _userDragBehavior = UIPushBehavior.init(items: [panGesture.view!], mode: UIPushBehaviorMode.continuous)
            _animator.addBehavior(_userDragBehavior!)
        }
        //用户完成拖动时，从animator移除PushBehavior
        _userDragBehavior?.pushDirection = CGVector(dx: panGesture.translation(in: self).x / 10.0, dy: 0)
        
        if panGesture.state == UIGestureRecognizerState.ended {
            _animator.removeBehavior(_userDragBehavior!)
            _userDragBehavior = nil
        }
    }

    //MARK: - 创建锚点
    func createAnchorForBall(ball: BallView) -> UIView {
        var archor: CGPoint = ball.center
        
        archor.y -= self.bounds.height / 4.0
        let blueBox: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        blueBox.backgroundColor = UIColor.blue
        blueBox.center = archor
        
        return blueBox
    }
    
    //MARK: - UIDynamics utility methods
    func applyDynamicBehaviors() {
        
        let behavior: UIDynamicBehavior = UIDynamicBehavior.init()
        applyAttachBehaviorForBalls(behavior: behavior)
        behavior.addChildBehavior(createGravityBehaviorForObjects(balls: _balls))
        behavior.addChildBehavior(createCollisionBehaviorForObjects(balls: _balls))
        behavior.addChildBehavior(createItemBehavior())
        
        _animator = UIDynamicAnimator.init(referenceView: self)
        _animator .addBehavior(behavior)
    }
    
    func applyAttachBehaviorForBalls(behavior: UIDynamicBehavior) {
        for i in 0...ballCount - 1 {
            let attachmentBehavior: UIDynamicBehavior = createAttachmentBehaviorForBallBearing(ballBearing: _balls[i], anchor: _archors[i])
            behavior .addChildBehavior(attachmentBehavior)
            
        }
    }
    
    func createAttachmentBehaviorForBallBearing(ballBearing: UIDynamicItem, anchor: UIDynamicItem) -> UIDynamicBehavior {
        let behavior: UIAttachmentBehavior = UIAttachmentBehavior.init(item: ballBearing, attachedToAnchor: anchor.center)
        return behavior
    }
    
    func createGravityBehaviorForObjects(balls: Array<BallView>) -> UIDynamicBehavior {
        let gravity: UIGravityBehavior = UIGravityBehavior.init(items: balls)
        gravity.magnitude = 10
        return gravity
    }
    
    func createCollisionBehaviorForObjects(balls: Array<BallView>) -> UIDynamicBehavior {
        return UICollisionBehavior.init(items: balls)
    }
    
    func createItemBehavior() -> UIDynamicItemBehavior {
        let itemBehavior: UIDynamicItemBehavior = UIDynamicItemBehavior.init(items: _balls)
        
        itemBehavior.elasticity = 1.0
        itemBehavior.allowsRotation = false
        itemBehavior.resistance = 1.0
        return itemBehavior
    }
    
    //MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        for ballBearing:UIDynamicItem in _balls {
            let anchor: CGPoint = _archors[_balls.index(of: ballBearing as! BallView)!].center
            let ballCenter: CGPoint = ballBearing.center
            context.move(to: anchor)
            context.addLine(to: ballCenter)
            context.setLineWidth(1.0)
            UIColor.black.setStroke()
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        for ball in _balls {
            ball .removeObserver(self, forKeyPath: "center")
        }
    }
    
}
















