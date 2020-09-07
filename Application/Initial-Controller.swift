//
//  Initial-Controller.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import AVFoundation
import MessageUI
import UIKit

class IC: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //Other Elements
    @IBOutlet weak var imageView: UIImageView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Other Declarations
    let applicationDelegate = UIApplication.shared.delegate! as! AppDelegate
    
    //Override Declarations
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        imageView.alpha = 0
        
        UIView.animate(withDuration: 3, delay: 0.3, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.applicationDelegate.currentlyAnimating = true
            
            if !preReleaseApplication
            {
                if let soundURL = Bundle.main.url(forResource: "Chime", withExtension: "mp3")
                {
                    var playableSound: SystemSoundID = 0
                    
                    AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                    AudioServicesPlaySystemSound(playableSound)
                }
            }
            
            self.imageView.alpha = 1
        }, completion: { (finishedAnimating: Bool) -> Void in
            if finishedAnimating
            {
                self.applicationDelegate.currentlyAnimating = false
                
                self.performSegue(withIdentifier: "initialSegue", sender: self)
            }
        })
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func skipButton(_ sender: Any)
    {
        applicationDelegate.currentlyAnimating = false
        
        self.performSegue(withIdentifier: "initialSegue", sender: self)
    }
}
