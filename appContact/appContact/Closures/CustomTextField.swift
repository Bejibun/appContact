//
//  CustomTextField.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/26/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import UIKit

class CustomTextfield: UITextField {
    
    typealias DidLabelEdit = (CustomTextfield) -> ()
    typealias InLabelEdit = (CustomTextfield) -> ()
    typealias EndLabelEdit = (CustomTextfield) -> ()
    
    var didlabelEdit: DidLabelEdit? {
        didSet {
            if didlabelEdit != nil {
                addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
            } else {
                removeTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
            }
        }
    }
    
    var inlabelEdit: InLabelEdit? {
        didSet {
            if inlabelEdit != nil {
                addTarget(self, action: #selector(inEditing), for: .editingChanged)
            } else {
                removeTarget(self, action: #selector(inEditing), for: .editingChanged)
            }
        }
    }
    
    var endlabelEdit: EndLabelEdit? {
        didSet {
            if endlabelEdit != nil {
                addTarget(self, action: #selector(doneEditing), for: .editingDidEnd)
            } else {
                removeTarget(self, action: #selector(doneEditing), for: .editingDidEnd)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(inEditing), for: .editingChanged)
        self.addTarget(self, action: #selector(doneEditing), for: .editingDidEnd)
    }
    
    // MARK: - Actions
    @objc func didBeginEditing()
    {
        if let handler = didlabelEdit {
            handler(self)
        }
    }
    
    @objc func inEditing()
    {
        if let handler = inlabelEdit {
            handler(self)
        }
    }
    
    @objc func doneEditing()
    {
        if let handler = endlabelEdit {
            handler(self)
        }
    }
}
