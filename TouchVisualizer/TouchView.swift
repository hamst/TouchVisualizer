//
//  TouchView.swift
//  TouchVisualizer
//

import UIKit

final public class TouchView: UIImageView {
    
    // MARK: - Public Variables
    internal weak var touch: UITouch?
    private weak var timer: NSTimer?
    private var _config: Configuration
    private var previousRatio: CGFloat = 1.0
    private var startDate: NSDate?
    private var lastTimeString: String!
    
    public var config: Configuration {
        get { return _config }
        set (value) {
            _config = value
            image = self.config.image
            tintColor = self.config.color
            timerLabel.textColor = self.config.color
        }
    }
    
    lazy var timerLabel: UILabel = {
        let size = CGSize(width: 200.0, height: 44.0)
        let bottom: CGFloat = 8.0
        var label = UILabel()
        
        label.frame = CGRect(x: -(size.width - CGRectGetWidth(self.frame)) / 2,
                             y: -size.height - bottom,
                             width: size.width,
                             height: size.height)
        
        label.font = UIFont(name: "Helvetica", size: 24.0)
        label.textAlignment = .Center
        self.addSubview(label)
        
        return label
    }()
    
    // MARK: - Object life cycle
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        _config = Configuration()
        super.init(frame: frame)
        
        self.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: _config.defaultSize)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Begin and end touching functions
    internal func beginTouch() {
        alpha = 1.0
        timerLabel.alpha = 0.0
        layer.transform = CATransform3DIdentity
        previousRatio = 1.0
        frame = CGRect(origin: frame.origin, size: _config.defaultSize)
        startDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 60.0, target: self, selector: #selector(self.update(_:)), userInfo: nil, repeats: true)
        
        NSRunLoop
            .mainRunLoop()
            .addTimer(timer!, forMode: NSRunLoopCommonModes)
        
        if _config.showsTimer {
            timerLabel.alpha = 1.0
        }
        
        if _config.showsTouchRadius {
            updateSize()
        }
    }
    
    func endTouch() {
        timer?.invalidate()
    }
    
    // MARK: - Update Functions
    internal func update(timer: NSTimer) {
        if let startDate = startDate {
            let interval = NSDate().timeIntervalSinceDate(startDate)
            let timeString = String(format: "%.02f", Float(interval))
            timerLabel.text = timeString
        }
        
        if _config.showsTouchRadius {
            updateSize()
        }
    }
    
    internal func updateSize() {
        if let touch = touch {
            let ratio = touch.majorRadius * 2.0 / _config.defaultSize.width
            if ratio != previousRatio {
                layer.transform = CATransform3DMakeScale(ratio, ratio, 1.0)
                previousRatio = ratio
            }
        }
    }
}