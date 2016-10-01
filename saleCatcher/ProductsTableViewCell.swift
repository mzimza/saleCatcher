//
//  ProductsTableViewCell.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 26/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//
//  As done here: https://www.raywenderlich.com/77974/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-1

import UIKit

// A protocol that the ProductsTableViewCell uses to inform its delegate of state change
protocol ProductsTableViewCellDelegate {
    // indicates that the given item has been deleted
    func productSelected(_ product: Product)
}

class ProductsTableViewCell: SwipeTableViewCell {
    
    let tickLabel: UILabel
    //You declare these properties as optionals, because you’ll set their values in ViewController.swift, not in TableViewCell‘s init method.
    var delegate : ProductsTableViewCellDelegate?
    var product: Product? {
        didSet {
            label.text = product!.displayInfo()
            label.strikeThrough =  false//!.completed
            itemCompleteLayer.isHidden = !(product?.selected)!
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
  
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    // utility method for creating the contextual cues
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 32.0)
            label.backgroundColor = UIColor.clear
            return label
        }
        
        // tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .right
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(tickLabel)
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0,
                                 width: kUICuesWidth, height: bounds.size.height)
    }
 
 
    //MARK: - horizontal pan gesture methods
    override func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            onDragReleaseLeft = frame.origin.x < -frame.size.width / 2.0
            onDragReleaseRight = frame.origin.x > frame.size.width / 2.0
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = UIColor.green
        }
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if onDragReleaseRight {
                if product != nil {
                    if !(product?.selected)! {
                        product!.selected = true
                        delegate!.productSelected(product!)
                        print(product!.selected)
                    }
                }
                itemCompleteLayer.isHidden = false // set background color for selected items
                // if the item is not being deleted, snap back to the original location
            }
            UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            let velocity = panGestureRecognizer.velocity(in: superview!)
            if fabs(translation.x) > fabs(translation.y) && velocity.x > 0 {
                return true
            }
            return false
        }
        return false
    }
    
}

