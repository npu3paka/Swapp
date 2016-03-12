//
//  BaseView.swift
//  Swapps
//
//  Created by Altimir Antonov on 3/1/16.
//  Copyright © 2016 Altimir Antonov. All rights reserved.
//

import Foundation
import UIKit

protocol BaseViewDelegate {
    func handlePan(recognizer: UIPanGestureRecognizer)
}

class BaseView: UIView {
    // MARK: -
    // MARK: Public Interface
    
    var delegate: BaseViewDelegate?
    
    // MARK: -
    // MARK: Constructor's
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // MARK: -
    // MARK: Desctructor's
    
    deinit {
        /* Clean up */
        clearUI()
    }
    
    // MARK: -
    // MARK: Override Base
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return super.hitTest(point, withEvent: event)
    }
    
    // MARK: -
    // MARK: Public Implementation
    /**
    Basic configuration of UI related elements in UIViewController, allocating memory set additional settings.
    */
    internal func setupUI() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    /**
     In order to Update UI.
     */
    internal func updateUI() {
        
    }
    
    /**
     Realise all UI related elements from memory of UIViewController, cleaning models, images etc...
     */
    internal func clearUI() {
        
    }
    
    // MARK: -
    // MARK: Private Implementation
    
    // MARK: -
    // MARK: Selectors && Actions
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // Emit delegate in BaseController
        delegate?.handlePan(recognizer)
    }
    
}