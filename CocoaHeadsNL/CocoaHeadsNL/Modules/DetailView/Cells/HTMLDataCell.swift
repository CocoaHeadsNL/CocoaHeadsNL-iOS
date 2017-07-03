//
//  HTMLDataCell.swift
//  CocoaHeadsNL
//
//  Created by Sidney de Koning on 29/05/2017.
//  Copyright © 2017 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

class HTMLDataCell: UITableViewCell {
    
    @IBOutlet weak var heighLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    var html: String? {
        didSet {
            guard let html = html, html != oldValue else { return }
            let inputText = "\(html)<style>body { font-family: '-apple-system-body','HelveticaNeue'; font-size:17px; }</style>"
            let attributedString = NSAttributedString(html: inputText)

            self.textView.attributedText = attributedString
            self.textView.isScrollEnabled = false
            self.textView.delegate = self
        }
    }
}

extension HTMLDataCell: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}
