//
//  NibView.swift
//
//  Created by Tom Brodhurst-Hill on 27/03/2016.
//  Copyright © 2016 BareFeetWare. Free to use and modify, without warranty.
//

import UIKit

open class NibView: BFWNibView, NibReplaceable {
    
    // MARK: - Variables & Functions
    
    private let autoSize = CGSize(width: UITableView.automaticDimension,
                                  height: UITableView.automaticDimension)
    
    // If this is set, it is used as intrinsicContentSize. Otherwise intrinsicContentSize taken as nib size.
    @IBInspectable open lazy var intrinsicSize: CGSize = {
        return self.autoSize
    }()
    
    static func sizeFromNib() -> CGSize {
        let size: CGSize
        let key = NSStringFromClass(self)
        if let reuseSize = sizeForKeyDictionary[key] {
            size = reuseSize
        } else {
            size = nibView()?.frame.size ?? .zero
            sizeForKeyDictionary[key] = size
        }
        return size
    }
    
    // MARK: - UpdateView mechanism
    
    /// Override in subclasses and call super. Update view and subview properties that are affected by properties of this class.
    open func updateView() {
    }
    
    open func setNeedsUpdateView() {
        needsUpdateView = true
        setNeedsLayout()
    }
    
    // MARK: - Private variables and functions.
    
    fileprivate var needsUpdateView = true
    private static var sizeForKeyDictionary = [String: CGSize]()

    fileprivate func updateViewIfNeeded() {
        if needsUpdateView {
            needsUpdateView = false
            updateView()
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// Convenience called by init(frame:) and init(coder:). Override in subclasses if required.
    open func commonInit() {
    }

    // MARK: - UIView overrides
    
    open override func awakeAfter(using coder: NSCoder) -> Any? {
        let view = replacedByNibView()
        if view != self {
            view.removePlaceholders()
        }
        return view
    }
    
    open override var intrinsicContentSize: CGSize {
        if intrinsicSize != autoSize {
            return intrinsicSize
        } else {
            return type(of: self).sizeFromNib()
        }
    }
    
    open override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // If storyboard instance is "default" (nil) then use the backgroundColor already set in xib or awakeFromNib (ie don't set it again).
            if newValue != nil {
                super.backgroundColor = newValue
            }
        }
    }
    
    open override func layoutSubviews() {
        updateViewIfNeeded()
        super.layoutSubviews()
    }
    
}

@objc public extension NibView {
    
    @objc func replacedByNibViewForInit() -> Self {
        return replacedByNibView()
    }
    
}
