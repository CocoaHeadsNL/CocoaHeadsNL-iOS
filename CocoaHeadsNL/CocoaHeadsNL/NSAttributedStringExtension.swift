//
//  NSAttributedStringExtension.swift
//  CocoaHeadsNL
//
//  Created by Sidney de Koning on 29/05/2017.
//  Copyright © 2017 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }

        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }
}
