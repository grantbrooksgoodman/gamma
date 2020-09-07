//
//  ShadowButton.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 28/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class ShadowButton: TranslatedButton
{
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Booleans
    private  var animateTouches: Bool!
    override var isEnabled:      Bool {
        didSet
        {
            layer.shadowColor     = isEnabled ? enabledShadowColour     : disabledShadowColour.cgColor
            layer.borderColor     = isEnabled ? enabledShadowColour     : disabledShadowColour.cgColor
            backgroundColor       = isEnabled ? enabledBackgroundColour : disabledBackgroundColour
        }
    }
    
    //UIColors
    private var enabledBackgroundColour: UIColor!
    private var enabledShadowColour:     CGColor!
    
    var disabledBackgroundColour = UIColor.gray
    var disabledShadowColour     = UIColor.darkGray
    
    //Other Declarations
    var fontSize: CGFloat!
    
    //--------------------------------------------------//
    
    //Class Declaration
    
    class func buttonWithType(_ buttonType: UIButton.ButtonType?) -> AnyObject
    {
        let currentButton = buttonWithType(buttonType) as! ShadowButton
        
        return currentButton
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        
        if animateTouches
        {
            layer.shadowOffset = CGSize(width: 0, height: 0)
            
            frame.origin.y = frame.origin.y + 3
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        if animateTouches
        {
            layer.shadowOffset = CGSize(width: 0, height: 4)
            
            frame.origin.y = frame.origin.y - 3
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with: event)
    }
    
    //--------------------------------------------------//
    
    //Constructor Function
    
    func initialiseLayer(animateTouches: Bool, backgroundColour: UIColor, customBorderFrame: CGRect?, customCornerRadius: CGFloat?, shadowColour: CGColor)
    {
        self.animateTouches = animateTouches
        
        enabledBackgroundColour = backgroundColour
        enabledShadowColour = shadowColour
        
        backgroundColor = isEnabled ? enabledBackgroundColour : disabledBackgroundColour
        
        layer.borderColor = isEnabled ? enabledShadowColour : disabledShadowColour.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = customCornerRadius ?? 10
        layer.masksToBounds = false
        layer.shadowColor = isEnabled ? enabledShadowColour : disabledShadowColour.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 1
    }
}
