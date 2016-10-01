//
//  SwipeTableViewCell.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 08/09/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

import UIKit
import Foundation



class SwipeTableViewCell: UITableViewCell {

    //MARK: PROPERTIES
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var onDragReleaseLeft = false
    var onDragReleaseRight = false
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
  //  var delegate: SwipeTableViewCellDelegate?

    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // create a label that renders the to-do item text
        label = StrikeThroughText(frame: CGRect.null)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        
        // remove the default blue highlight for selected cells
        selectionStyle = .none
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
 
        // add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red:0.85, green:0.87, blue:0.92, alpha:1.0).cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0)
        
        
        // add a pan recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(ProductsTableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0
    let kUICuesWidth: CGFloat = 50.0
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure the gradient layer occupies the full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
                             width: bounds.size.width - kLabelLeftMargin,
                             height: bounds.size.height)

    }
    
    //MARK: - horizontal pan gesture methods
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the item far enough to initiate an action?
            onDragReleaseLeft = frame.origin.x < -frame.size.width / 2.0
            onDragReleaseRight = frame.origin.x > frame.size.width / 2.0
        }
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
        }
    }

    // allow only verical gestures
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
}
