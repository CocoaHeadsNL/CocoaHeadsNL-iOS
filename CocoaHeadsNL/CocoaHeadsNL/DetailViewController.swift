//
//  DetailViewController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 10/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import UIkit

class DetailViewController : UIViewController {
    var selectedObject: PFObject?
    
    @IBOutlet weak var sponsorTitle: UILabel!
    @IBOutlet weak var sponsorLocation: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var descriptiveTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.printSelectedObject()
        
        //selectedObject can either be vacancy or meetup info
        //Need to make distinction for setting up UI between vacancy and meetup info.
        //Missing logo of sponsor on meetup. Needs to be added somehow (parse?)
        
        self.sponsorTitle.text = selectedObject?.valueForKey("locationName") as? String
        self.sponsorLocation.text = "Amsterdam"
        self.linkButton.titleLabel?.text = "SomeLink"
        self.descriptiveTitle.text = selectedObject?.valueForKey("name") as? String
        
        if var meetupDescription = selectedObject?.valueForKey("meetup_description") as? String {
            self.textView.attributedText = NSAttributedString(data: meetupDescription.dataUsingEncoding(NSUTF32StringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
        } else {
            self.textView.attributedText = nil
        }
    }
    
    func printSelectedObject()
    {
        if let object = selectedObject {
        println(selectedObject)
        }
    }
}
