//
//  Main-Controller.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import PKHUD
import FirebaseAuth
import FirebaseDatabase
import Firebase

class MC: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UIButtons
    @IBOutlet weak var codeNameButton:     UIButton!
    @IBOutlet weak var informationButton:  UIButton!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    @IBOutlet weak var subtitleButton:     UIButton!
    
    //UILabels
    @IBOutlet weak var bundleVersionLabel:                UILabel!
    @IBOutlet weak var projectIdentifierLabel:            UILabel!
    @IBOutlet weak var skuLabel:                          UILabel!
    
    //UIViews
    @IBOutlet weak var extraneousInformationView: UIView!
    @IBOutlet weak var preReleaseInformationView: UIView!
    
    @IBOutlet weak var testLabel: UILabel!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    override var prefersStatusBarHidden:            Bool                 { return false }
    override var preferredStatusBarStyle:           UIStatusBarStyle     { return .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    var buildInstance: Build!
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    func initialiseController()
    {
        //Be sure to change the values below.
        //The build number string when archiving.
        //The code name of the application.
        //The editor header file values.
        //The first digit in the formatted version number.
        //The value of the pre-release application boolean.
        //The value of the prefers status bar boolean.
        
        buildInstance = Build(withType: .mainController, instanceArray: [bundleVersionLabel!, projectIdentifierLabel!, skuLabel!, codeNameButton!, extraneousInformationView!, informationButton!, sendFeedbackButton!, subtitleButton!, self])
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setBackgroundImage(view, imageName: "Background Image")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            //self.performSegue(withIdentifier: "createAccountFromMainSegue", sender: self)
            self.performSegue(withIdentifier: "welcomeFromMainSegue", sender: self)
            
            //            AlertKit().confirmationAlertController(title: nil,
            //                                                   message: nil,
            //                                                   cancelConfirmTitles: [:],
            //                                                   confirmationDestructive: true,
            //                                                   confirmationPreferred: true,
            //                                                   networkDepedent: true)
            //            { (didConfirm) in
            //                if let confirmed = didConfirm
            //                {
            //                    print("confirmed? \(confirmed)")
            //                }
            //            }
            
            //            AlertKit().errorAlertController(title: "oof",
            //                                            message: "it seems that your mother is a cunt",
            //                                            dismissButtonTitle: nil,
            //                                            additionalSelectors: ["Print Hi": #selector(MC.printHi)],
            //                                            preferredAdditionalSelector: 0,
            //                                            canFileReport: true,
            //                                            extraInfo: nil,
            //                                            metaData: [#file, #function, #line],
            //                                            networkDependent: true)
            
            UserSerialiser().getUser(withIdentifier: "88UWFQO7QfPDEpvIrOqa1rWLrlx2") { (wrappedUser, getUserErrorDescriptor) in
                if let returnedUser = wrappedUser
                {
                    print("got user \(returnedUser.firstName!) who has swiped on \(returnedUser.swipedOnIdentifiers ?? [])")
                }
                else
                {
                    guard getUserErrorDescriptor != nil else { printReport("An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line]); return }
                    
                    printReport(getUserErrorDescriptor!, errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        initialiseController()
        
        if informationDictionary["subtitleExpiryString"] == "Evaluation period ended." && preReleaseApplication
        {
            view.addBlur(withActivityIndicator: false, withStyle: .light, withTag: 1)
            view.isUserInteractionEnabled = false
        }
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func codeNameButton(_ sender: AnyObject)
    {
        buildInstance.codeNameButtonAction()
    }
    
    @IBAction func informationButton(_ sender: AnyObject)
    {
        buildInstance.displayBuildInformation()
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    @IBAction func subtitleButton(_ sender: Any)
    {
        buildInstance.subtitleButtonAction(withButton: sender as! UIButton)
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    @objc func printHi()
    {
        print("hi")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}
