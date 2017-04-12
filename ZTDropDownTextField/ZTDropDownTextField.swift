//
//  ZTDropDownTextField.swift
//  ZTDropDownTextField
//
//  Created by Ziyang Tan on 7/30/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

// MARK: Animation Style Enum
public enum ZTDropDownAnimationStyle {
    case basic
    case slide
    case expand
    case flip
}

// MARK: Dropdown Delegate
public protocol ZTDropDownTextFieldDataSourceDelegate: NSObjectProtocol {
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, numberOfRowsInSection section: Int) -> Int
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    func dropDownTextField(_ dropDownTextField: ZTDropDownTextField, didSelectRowAtIndexPath indexPath: IndexPath)
}

open class ZTDropDownTextField: UITextField {
    
    // MARK: Instance Variables
    open var dropDownTableView: UITableView!
    open var rowHeight:CGFloat = 50
    open var dropDownTableViewHeight: CGFloat = 150
    open var animationStyle: ZTDropDownAnimationStyle = .basic
    open weak var dataSourceDelegate: ZTDropDownTextFieldDataSourceDelegate?
    fileprivate var heightConstraint: NSLayoutConstraint!
    
    // MARK: Init Methods
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    
    // MARK: Setup Methods
    fileprivate func setupTextField() {
        addTarget(self, action: #selector(ZTDropDownTextField.editingChanged(_:)), for:.editingChanged)
    }
    
    fileprivate func setupTableView() {
        if dropDownTableView == nil {
            
            dropDownTableView = UITableView()
            dropDownTableView.backgroundColor = UIColor.white
            dropDownTableView.layer.cornerRadius = 10.0
            dropDownTableView.layer.borderColor = UIColor.lightGray.cgColor
            dropDownTableView.layer.borderWidth = 1.0
            dropDownTableView.showsVerticalScrollIndicator = false
            dropDownTableView.delegate = self
            dropDownTableView.dataSource = self
            dropDownTableView.estimatedRowHeight = rowHeight
            
            superview!.addSubview(dropDownTableView)
            superview!.bringSubview(toFront: dropDownTableView)
            
            dropDownTableView.translatesAutoresizingMaskIntoConstraints = false
            
            let leftConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let rightConstraint =  NSLayoutConstraint(item: dropDownTableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            heightConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: dropDownTableViewHeight)
            let topConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 1)
            
            NSLayoutConstraint.activate([leftConstraint, rightConstraint, heightConstraint, topConstraint])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ZTDropDownTextField.tapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.cancelsTouchesInView = false
            superview!.addGestureRecognizer(tapGesture)
        }
        
    }
    
    fileprivate func tableViewAppearanceChange(_ appear: Bool) {
        switch animationStyle {
        case .basic:
            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            basicAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            basicAnimation?.toValue = appear ? 1 : 0
            dropDownTableView.pop_add(basicAnimation, forKey: "basic")
        case .slide:
            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            basicAnimation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            basicAnimation?.toValue = appear ? dropDownTableViewHeight : 0
            heightConstraint.pop_add(basicAnimation, forKey: "heightConstraint")
        case .expand:
            let springAnimation = POPSpringAnimation(propertyNamed: kPOPViewSize)
            springAnimation?.springSpeed = dropDownTableViewHeight / 100
            springAnimation?.springBounciness = 10.0
            let width = appear ? frame.width : 0
            let height = appear ? dropDownTableViewHeight : 0
            springAnimation?.toValue = NSValue(cgSize: CGSize(width: width, height: height))
            dropDownTableView.pop_add(springAnimation, forKey: "expand")
        case .flip:
            var identity = CATransform3DIdentity
            identity.m34 = -1.0/1000
            let angle = appear ? CGFloat(0) : CGFloat(M_PI_2)
            let rotationTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.dropDownTableView.layer.transform = rotationTransform
            })
        }
    }
    
    // MARK: Target Methods
    func tapped(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: superview)
        if !dropDownTableView.frame.contains(location) {
            if (dropDownTableView) != nil {
                self.tableViewAppearanceChange(false)
            }
        }
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text!.characters.count > 0 {
            setupTableView()
            self.tableViewAppearanceChange(true)
        } else {
            if (dropDownTableView) != nil {
                self.tableViewAppearanceChange(false)
            }
        }
    }
    
}

// Mark: UITableViewDataSoruce
extension ZTDropDownTextField: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.responds(to: Selector("dropDownTextField:numberOfRowsInSection:")) {
                return dataSourceDelegate.dropDownTextField(self, numberOfRowsInSection: section)
            }
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.responds(to: Selector("dropDownTextField:cellForRowAtIndexPath:")) {
                return dataSourceDelegate.dropDownTextField(self, cellForRowAtIndexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
}

// Mark: UITableViewDelegate
extension ZTDropDownTextField: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.responds(to: Selector("dropDownTextField:didSelectRowAtIndexPath:")) {
                dataSourceDelegate.dropDownTextField(self, didSelectRowAtIndexPath: indexPath)
            }
        }
        self.tableViewAppearanceChange(false)
    }
}
