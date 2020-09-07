//
//  CardController.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 16/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import Koloda

class CardController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UIButtons
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    //UILabels
    @IBOutlet weak var codeNameLabel:   UILabel!
    @IBOutlet weak var preReleaseLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var logoTypeImageView: UIImageView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    var animalArray: [Animal]!
    var buildInstance: Build!
    
    var conversationsToPass: [Conversation]?
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    func initialiseController()
    {
        lastInitialisedController = self
        
        buildInstance = Build(withType: .genericController, instanceArray: [codeNameLabel!, logoTypeImageView!, preReleaseLabel!, sendFeedbackButton!, self])
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "conversationFromCardSegue"
        {
            let destinationController = segue.destination as! ConversationController
            
            destinationController.conversationArray = conversationsToPass
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        AnimalSerialiser().getRandomAnimals(amountToGet: nil) { (wrappedReturnedAnimalIdentifiers, getRandomAnimalsError) in
            if let returnedAnimalIdentifiers = wrappedReturnedAnimalIdentifiers
            {
                if let randomAnimalsError = getRandomAnimalsError
                {
                    printReport(randomAnimalsError, errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                }
                
                AnimalSerialiser().getAnimals(withIdentifiers: returnedAnimalIdentifiers) { (wrappedReturnedAnimals, getAnimalsErrors) in
                    if let returnedAnimals = wrappedReturnedAnimals
                    {
                        self.animalArray = returnedAnimals
                        self.kolodaView.dataSource = self
                        self.kolodaView.delegate = self
                    }
                    else
                    {
                        //IF MORE THAN 4 OPTIONS, DO IT LIKE THIS:
                        AlertKit().errorAlertController(title: nil,
                                                        message: nil,
                                                        dismissButtonTitle: nil,
                                                        additionalSelectors: nil,
                                                        preferredAdditionalSelector: nil,
                                                        canFileReport: true,
                                                        extraInfo: getAnimalsErrors!.joined(separator: "\n"),
                                                        metaData: [#file, #function, #line],
                                                        networkDependent: true)
                    }
                }
            }
            else
            {
                AlertKit().errorAlertController(title: nil,
                                                message: nil,
                                                dismissButtonTitle: nil,
                                                additionalSelectors: nil,
                                                preferredAdditionalSelector: nil,
                                                canFileReport: true,
                                                extraInfo: getRandomAnimalsError!,
                                                metaData: [#file, #function, #line],
                                                networkDependent: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        initialiseController()
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func messagesButton(_ sender: Any)
    {
        UserSerialiser().getUser(withIdentifier: "88UWFQO7QfPDEpvIrOqa1rWLrlx2") { (wrappedUser, getUserError) in
            if let returnedUser = wrappedUser,
                let inConversations = returnedUser.participatingIn
            {
                self.conversationsToPass = inConversations
                self.performSegue(withIdentifier: "conversationFromCardSegue", sender: self)
            }
            else
            {
                print(getUserError!)
            }
        }
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}

extension CardController: KolodaViewDataSource
{
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int
    {
        return animalArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed
    {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection)
    {
        if direction == .right || direction == .bottomRight || direction == .topRight
        {
            if let swipedOn = currentUser?.swipedOnIdentifiers
            {
                var mutableSwipedOn = swipedOn
                mutableSwipedOn.append(animalArray[index].associatedIdentifier)
                currentUser?.swipedOnIdentifiers = mutableSwipedOn
                
                GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser!.associatedIdentifier!)", withData: ["swipedOn": mutableSwipedOn]) { (updateValueErrorDescriptor) in
                    if let updateValueError = updateValueErrorDescriptor
                    {
                        print("uh oh")
                    }
                    else
                    {
                        
                    }
                }
            }
            else
            {
                currentUser?.swipedOnIdentifiers = [animalArray[index].associatedIdentifier]
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView
    {
        let cardView = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)?[0] as! CardView
        
        cardView.updateFrame()
        cardView.nameLabel.updateFrame()
        cardView.subtitleLabel.updateFrame()
        cardView.informationButton.updateFrame()
        cardView.profileImageView.updateFrame()
        
        cardView.nameLabel.text = animalArray[index].animalName.uppercased()
        
        let intrinsicContentWidth = cardView.nameLabel.sizeThatFits(cardView.nameLabel.intrinsicContentSize).width
        let adjustedSize = (intrinsicContentWidth + cardView.nameLabel.frame.origin.x) + 5
        
        if adjustedSize > cardView.informationButton.frame.origin.x
        {
            cardView.nameLabel.frame.size.width = intrinsicContentWidth
            cardView.nameLabel.frame.size.width -= (adjustedSize - cardView.informationButton.frame.origin.x)
        }
        else
        {
            cardView.nameLabel.frame.size.width = intrinsicContentWidth
            cardView.nameLabel.frame.size.width += 5
        }
        
        cardView.subtitleLabel.text = "\(animalArray[index].isMale ? "Male, " : "Female, ")\(Int(animalArray[index].ageInWeeks))wks."
        
        cardView.profileImageView.contentMode = .scaleAspectFill
        
        if let imageDataArray = self.animalArray[index].associatedImageData,
            let imageData = Data(base64Encoded: imageDataArray[0], options: .ignoreUnknownCharacters)
        {
            cardView.profileImageView.image = UIImage(data: imageData)
        }
        else
        {
            let noImageLabel = UILabel(frame: f.frame(CGRect(x: 0, y: 0, width: 150, height: 20)))
            noImageLabel.center = cardView.profileImageView.center
            noImageLabel.font = UIFont(name: "SFUIText-Semibold", size: 20)
            noImageLabel.text = "No Profile Image"
            noImageLabel.textAlignment = .center
            noImageLabel.textColor = .white
            
            cardView.profileImageView.addSubview(noImageLabel)
            cardView.profileImageView.bringSubviewToFront(noImageLabel)
        }
        
        cardView.informationButton.initialiseLayer(animateTouches: true,
                                                   backgroundColour: cardView.informationButton.backgroundColor!,
                                                   customBorderFrame: nil,
                                                   customCornerRadius: cardView.informationButton.frame.size.width / 2,
                                                   shadowColour: getColour(withHexadecimalString: "#66A0CE").cgColor)
        
        ancillaryRound(forViews: [cardView.nameLabel, cardView.subtitleLabel])
        roundCorners(forViews: [cardView.profileImageView], withCornerType: 0)
        
        return cardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView?
    {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

extension CardController: KolodaViewDelegate
{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView)
    {
        koloda.reloadData()
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat?
    {
        return 0.43
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int)
    {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
}

extension UIView
{
    func updateFrame()
    {
        frame = f.frame(frame)
    }
}
