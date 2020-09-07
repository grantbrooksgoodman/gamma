//
//  ConversationController.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 24/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

import MessageKit
import FirebaseDatabase

class ConversationController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UILabels
    @IBOutlet weak var codeNameLabel:   UILabel!
    @IBOutlet weak var preReleaseLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var logoTypeImageView: UIImageView!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    var buildInstance: Build!
    var conversationArray: [Conversation]! = []
    
    var selectedIndex = 0
    
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
        if segue.identifier == "messagesFromConversationSegue"
        {
            let destinationController = segue.destination as! MessagesController
            
            destinationController.messageArray = conversationArray[selectedIndex].associatedMessages
            destinationController.otherUser = conversationArray[selectedIndex].otherUser
            destinationController.conversationIdentifier = conversationArray[selectedIndex].associatedIdentifier
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var processedConversations = 0
        
        for individualConversation in conversationArray
        {
            let otherUserIdentifier = individualConversation.participantIdentifiers.filter({$0 != accountIdentifier})[0]
            
            UserSerialiser().getUser(withIdentifier: otherUserIdentifier) { (wrappedUser, getUserError) in
                if let returnedUser = wrappedUser
                {
                    individualConversation.otherUser = returnedUser
                    processedConversations += 1
                    
                    if processedConversations == self.conversationArray.count
                    {
                        self.chatTableView.dataSource = self
                        self.chatTableView.delegate = self
                        self.chatTableView.reloadData()
                    }
                }
                else
                {
                    printReport(getUserError!, errorCode: nil, isFatal: true, metaData: [#file, #function, #line])
                }
            }
        }
        
        navigationController?.title = "Messages"
        
        //testConversationCreation(alsoDelete: false)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        initialiseController()
        
        chatTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Database.database().reference().child("allConversations").removeAllObservers()
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    @IBAction func addButton(_ sender: Any)
    {
        createConvo()
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    func testConversationCreation(alsoDelete: Bool)
    {
        MessageSerialiser().createMessage(fromAccountWithIdentifier: "88UWFQO7QfPDEpvIrOqa1rWLrlx2", inConversationWithIdentifier: nil, messageContent: "First message.") { (wrappedCreateMessageIdentifier, wrappedCreateMessageErrorDescriptor) in
            if let returnedIdentifier = wrappedCreateMessageIdentifier
            {
                ConversationSerialiser().createConversation(initialMessageIdentifier: returnedIdentifier, participantIdentifiers: ["88UWFQO7QfPDEpvIrOqa1rWLrlx2", "DyLM37uFUUcVHhCn6OGwXNeQfzf2"]) { (wrappedCreateConversationIdentifier, wrappedCreateConversationErrorDescriptor) in
                    if let conversationIdentifier = wrappedCreateConversationIdentifier
                    {
                        MessageSerialiser().createMessage(fromAccountWithIdentifier: "DyLM37uFUUcVHhCn6OGwXNeQfzf2", inConversationWithIdentifier: conversationIdentifier, messageContent: "hi") { (wrappedIdentifier, wrappedErrorDescriptor) in
                            if wrappedIdentifier != nil
                            {
                                print("Successfully created conversation!")
                                
                                if alsoDelete
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                                        ConversationSerialiser().deleteConversation(withIdentifier: conversationIdentifier) { (wrappedErrorDescriptor) in
                                            if let deleteConversationError = wrappedErrorDescriptor
                                            {
                                                printReport(deleteConversationError, errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                                            }
                                            else
                                            {
                                                print("Successfully deleted conversation!")
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                printReport(wrappedErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                            }
                        }
                    }
                    else
                    {
                        printReport(wrappedCreateConversationErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                    }
                }
            }
            else
            {
                printReport(wrappedCreateMessageErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
            }
        }
    }
    
    @objc func goBack()
    {
        navigationController?.popViewController(animated: true)
    }
    
    func createConvo()
    {
        MessageSerialiser().createMessage(fromAccountWithIdentifier: "88UWFQO7QfPDEpvIrOqa1rWLrlx2", inConversationWithIdentifier: nil, messageContent: "First message.") { (wrappedCreateMessageIdentifier, wrappedCreateMessageErrorDescriptor) in
            if let returnedIdentifier = wrappedCreateMessageIdentifier
            {
                ConversationSerialiser().createConversation(initialMessageIdentifier: returnedIdentifier, participantIdentifiers: ["88UWFQO7QfPDEpvIrOqa1rWLrlx2", "DyLM37uFUUcVHhCn6OGwXNeQfzf2"]) { (wrappedCreateConversationIdentifier, wrappedCreateConversationErrorDescriptor) in
                    if let conversationIdentifier = wrappedCreateConversationIdentifier
                    {
                        MessageSerialiser().createMessage(fromAccountWithIdentifier: "DyLM37uFUUcVHhCn6OGwXNeQfzf2", inConversationWithIdentifier: conversationIdentifier, messageContent: "Second message.") { (wrappedIdentifier, wrappedErrorDescriptor) in
                            if wrappedIdentifier != nil
                            {
                                PresentationManager().successAlertController(withTitle: nil, withMessage: nil, withCancelButtonTitle: nil, withAlternateSelectors: ["Go Back": #selector(self.goBack)], preferredActionIndex: nil)
                            }
                            else
                            {
                                printReport(wrappedErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: true, metaData: [#file, #function, #line])
                            }
                        }
                    }
                    else
                    {
                        printReport(wrappedCreateConversationErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                    }
                }
            }
            else
            {
                printReport(wrappedCreateMessageErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
            }
        }
    }
}

extension ConversationController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let contextItem = UIContextualAction(style: .destructive, title: "Unmatch") {  (contextualAction, view, boolValue) in
            PresentationManager().confirmationAlertController(withTitle: "Are you sure?",
                                                              withMessage: "Would you really like to unmatch with \(self.conversationArray[indexPath.row].otherUser.firstName!)?",
                withConfirmationButtonTitle: "Unmatch",
                withCancelButtonTitle: nil,
                confirmationDestructive: true,
                confirmationPreferred: false,
                networkDependent: true) { (wrappedDidConfirm) in
                    if let didConfirm = wrappedDidConfirm
                    {
                        if didConfirm
                        {
                            ConversationSerialiser().deleteConversation(withIdentifier: self.conversationArray[indexPath.row].associatedIdentifier) { (wrappedErrorDescriptor) in
                                if let deleteConversationError = wrappedErrorDescriptor
                                {
                                    PresentationManager().errorAlertController(withTitle: nil,
                                                                               withMessage: "The conversation could not be deleted.",
                                                                               extraneousInformation: deleteConversationError,
                                                                               withCancelButtonTitle: nil,
                                                                               withAlternateSelectors: nil,
                                                                               preferredActionIndex: nil,
                                                                               withFileName: #file,
                                                                               withLineNumber: #line,
                                                                               withFunctionTitle: #function,
                                                                               networkDependent: true,
                                                                               canFileReport: true)
                                    
                                    printReport(deleteConversationError, errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                                }
                                else
                                {
                                    self.conversationArray.remove(at: indexPath.row)
                                    tableView.reloadData()
                                    
                                    print("Conversation deleted successfully.")
                                }
                            }
                        }
                    }
            }
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "currentCell") as! ChatCell
        
        Database.database().reference().child("allConversations").child(conversationArray[indexPath.row].associatedIdentifier).child("associatedMessages").observe(.childAdded, with: { (returnedSnapshot) in
            if let newMessageIdentifier = returnedSnapshot.value as? String
            {
                var doIt = true
                
                for individualMessage in self.conversationArray[indexPath.row].associatedMessages
                {
                    if individualMessage.associatedIdentifier == newMessageIdentifier
                    {
                        doIt = false
                    }
                }
                
                if doIt
                {
                    MessageSerialiser().getMessage(withIdentifier: newMessageIdentifier) { (wrappedMessage, getMessageError) in
                        if let returnedMessage = wrappedMessage
                        {
                            self.conversationArray[indexPath.row].associatedMessages.append(returnedMessage)
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                        else
                        {
                            printReport(getMessageError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metaData: [#file, #function, #line])
                        }
                    }
                }
            }
        })
        
        currentCell.nameLabel.text = conversationArray[indexPath.row].otherUser.firstName!
        currentCell.previewLabel.text = conversationArray[indexPath.row].associatedMessages.last!.messageContent!
        
        if currentCell.previewLabel.text!.count < 45
        {
            currentCell.previewLabel.numberOfLines = 1
        }
        else
        {
            currentCell.previewLabel.numberOfLines = 2
        }
        
        currentCell.previewLabel.sizeToFit()
        
        if let imageDataString = conversationArray[indexPath.row].otherUser.profileImageData,
            let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
        {
            currentCell.profileImageView.image = UIImage(data: imageData)
            currentCell.profileImageView.layer.cornerRadius = currentCell.profileImageView.frame.size.width / 2
            currentCell.profileImageView.layer.masksToBounds = false
            currentCell.profileImageView.clipsToBounds = true
        }
        else
        {
            currentCell.avatarView.set(avatar: Avatar(image: nil, initials: "\(conversationArray[indexPath.row].otherUser.firstName.stringCharacters[0].uppercased())"))
        }
        
        currentCell.unreadView.isHidden = conversationArray[indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last?.readDate != nil
        currentCell.unreadView.layer.cornerRadius = 5
        currentCell.unreadView.clipsToBounds = true
        
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let lastMessage = conversationArray[indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last
        {
            if lastMessage.readDate == nil
            {
                lastMessage.readDate = Date(timeIntervalSince1970: 0)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "messagesFromConversationSegue", sender: self)
        
        Database.database().reference().child("allConversations").removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return conversationArray.count
    }
}
