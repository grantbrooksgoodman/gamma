//
//  LivingSituationController.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class LivingSituationController: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //Other Elements
    @IBOutlet weak var livingSituationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var somethingElseTextView: UITextView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //CGRect Declarations
    var originalFrame:                      CGRect!
    var originalSomethingElseTextViewFrame: CGRect!
    
    var createAccountController: CreateAccountController!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidLoad()
    {
        livingSituationSegmentedControl.setTitleTextAttributes([.foregroundColor: getColour(withHexadecimalString: "#4B4B4B"), .font: UIFont(name: "SFUIText-Bold", size: 12)!], for: .normal)
        
        //Add a rounded border to the «somethingElseTextView».
        somethingElseTextView.layer.borderWidth  = 2
        somethingElseTextView.layer.cornerRadius = 10
        
        somethingElseTextView.layer.borderColor = getColour(withHexadecimalString: "#E1E0E1").cgColor
        
        somethingElseTextView.clipsToBounds       = true
        somethingElseTextView.layer.masksToBounds = true
        
        somethingElseTextView.tag = aTagFor("somethingElseTextView")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if let unwrappedCreateAccountController = self.parent as? CreateAccountController
        {
            createAccountController = unwrappedCreateAccountController
        }
        else
        {
            printReport("No CreateAccountController.", errorCode: nil, isFatal: true, metaData: [#file, #function, #line])
        }
        
        originalFrame = view.frame
        originalSomethingElseTextViewFrame = somethingElseTextView.frame
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func livingSituationSegmentedControl(_ sender: Any)
    {
        somethingElseTextView.resignFirstResponder()
        createAccountController.continueButton.isEnabled = true
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    /**
     Called when the keyboard begins displaying.
     
     - Parameter withNotification: The Notification calling the function.
     */
    @objc func keyboardDidShow(_ withNotification: Notification)
    {
        //Get the keyboard's frame.
        if let keyboardFrame: NSValue = withNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            //Convert the keyboard frame to a CGRect.
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            //Get the point where the keyboard begins.
            let minimumValue = keyboardRectangle.origin.y
            
            //If the keyboard obscures part of the view.
            if view.frame.maxY > minimumValue
            {
                //While the keyboard obscures part of the view.
                while minimumValue < view.frame.maxY
                {
                    //If decreasing the «instructionTextView's» font by 1 would make the size less than 10.
                    if view.frame.height - 1 < 50
                    {
                        //f***ed
                    }
                    else //If decreasing the «instructionTextView's» font by 1 would not make the size less than 10.
                    {
                        //Decrease the instruction text view's font size by 1.
                        somethingElseTextView.frame.size.height -= 1
                        view.frame.size.height -= 1
                        
                        if !(view.frame.maxY > minimumValue)
                        {
                            UIView.animate(withDuration: 0.3) {
                                self.somethingElseTextView.frame.size.height -= 4
                            }
                        }
                    }
                }
            }
        }
    }
}

extension LivingSituationController: UITextViewDelegate
{
    func textViewDidEndEditing(_ textView: UITextView)
    {
        UIView.animate(withDuration: 0.4) {
            self.view.frame.size.height = self.originalFrame.size.height
            self.somethingElseTextView.frame = self.originalSomethingElseTextViewFrame
        }
        
        createAccountController.continueButton.isEnabled = (livingSituationSegmentedControl.selectedSegmentIndex > -1) || (textView.text.noWhiteSpaceLowerCaseString != "")
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (text == "\n")
        {
            textView.resignFirstResponder()
        }
        
        if text.noWhiteSpaceLowerCaseString != ""
        {
            livingSituationSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        createAccountController.continueButton.isEnabled = (livingSituationSegmentedControl.selectedSegmentIndex > -1) || (textView.text.noWhiteSpaceLowerCaseString != "")
    }
}
