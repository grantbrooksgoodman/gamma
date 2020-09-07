//
//  ConversationSerialiser.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 02/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class ConversationSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    func deleteConversation(withIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void)
    {
        ConversationSerialiser().getConversation(withIdentifier: withIdentifier) { (wrappedConversation, getConversationError) in
            if let returnedConversation = wrappedConversation
            {
                self.removeConversationReference(fromAccountIdentifiers: returnedConversation.participantIdentifiers, withConversationIdentifier: withIdentifier) { (wrappedRemoveConversationReferenceErrorDescriptors) in
                    if let removeConversationReferenceErrors = wrappedRemoveConversationReferenceErrorDescriptors
                    {
                        completionHandler(removeConversationReferenceErrors)
                    }
                    else
                    {
                        if let messageIdentifiers = returnedConversation.messageIdentifiers()
                        {
                            MessageSerialiser().deleteMessages(withIdentifiers: messageIdentifiers) { (wrappedDeleteMessagesErrorDescriptors) in
                                if let deleteMessagesErrors = wrappedDeleteMessagesErrorDescriptors
                                {
                                    completionHandler(deleteMessagesErrors.joined(separator: "\n"))
                                }
                                else
                                {
                                    self.removeConversation(withIdentifier) { (wrappedErrorDescriptor) in
                                        if let removeConversationError = wrappedErrorDescriptor
                                        {
                                            completionHandler(removeConversationError)
                                        }
                                        else
                                        {
                                            completionHandler(nil)
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            completionHandler("Unable to get Message identifiers from Conversation.")
                        }
                    }
                }
            }
            else
            {
                completionHandler(getConversationError!)
            }
        }
    }
    
    func removeConversation(_ withIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void)
    {
        GenericSerialiser().updateValue(onKey: "/allConversations", withData: [withIdentifier: NSNull()]) { (wrappedError) in
            if let updateValueError = wrappedError
            {
                completionHandler(updateValueError.localizedDescription)
            }
            else
            {
                completionHandler(nil)
            }
        }
    }
    
    func removeConversationReference(fromAccountIdentifiers: [String], withConversationIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void)
    {
        var errorDescriptorArray: [String] = []
        
        var amountProcessed = 0
        
        UserSerialiser().getUsers(withIdentifiers: fromAccountIdentifiers) { (wrappedUsers, wrappedErrorDescriptors) in
            if let returnedUsers = wrappedUsers
            {
                for individualUser in returnedUsers
                {
                    if let participatingIn = individualUser.conversationIdentifiers()
                    {
                        let filteredConversations = participatingIn.filter({$0 != withConversationIdentifier})
                        
                        GenericSerialiser().setValue(onKey: "/allUsers/\(individualUser.associatedIdentifier!)/participatingIn", withData: (filteredConversations.count == 0 ? ["!"] : filteredConversations)) { (wrappedError) in
                            if let setValueError = wrappedError
                            {
                                errorDescriptorArray.append(setValueError.localizedDescription)
                            }
                            
                            amountProcessed += 1
                            
                            if amountProcessed == fromAccountIdentifiers.count
                            {
                                completionHandler(errorDescriptorArray.count == 0 ? nil : errorDescriptorArray.joined(separator: "\n"))
                            }
                        }
                    }
                }
            }
            else
            {
                if let getUsersErrors = wrappedErrorDescriptors
                {
                    var allErrors = getUsersErrors
                    allErrors.append(contentsOf: errorDescriptorArray)
                    
                    completionHandler(allErrors.joined(separator: "\n"))
                }
                else
                {
                    completionHandler("Unable to get Users, but no error either.")
                }
            }
        }
    }
    
    /**
     Creates a **Conversation** on the server.
     
     - Parameter initialMessageIdentifier: The identifier of the first **Message** in the new **Conversation.**
     - Parameter participantIdentifiers: The identifiers of the **Conversation's** participants.
     
     - Parameter returnedIdentifier: The identifier of the new **Conversation** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createConversation(initialMessageIdentifier: String, participantIdentifiers: [String], completionHandler: @escaping(_ returnedIdentifier: String?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Creating Conversation...") }
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["associatedMessages"] = [initialMessageIdentifier]
        dataBundle["conversationParticipants"] = participantIdentifiers
        dataBundle["lastModified"] = secondaryDateFormatter.string(from: Date())
        
        //Generate a key for the new Conversation.
        if let generatedKey = Database.database().reference().child("/allConversations/").childByAutoId().key
        {
            //Add the data bundle to the new conversation.
            GenericSerialiser().updateValue(onKey: "/allConversations/\(generatedKey)", withData: dataBundle) { (wrappedError) in
                if let returnedError = wrappedError
                {
                    if verboseFunctionExposure { print("Finished creating Conversation!") }
                    
                    completionHandler(nil, returnedError.localizedDescription)
                }
                else
                {
                    //Get the Users participating in this new Conversation.
                    UserSerialiser().getUsers(withIdentifiers: participantIdentifiers) { (wrappedUsers, wrappedErrorDescriptors) in
                        if let returnedUsers = wrappedUsers
                        {
                            var amountProcessed = 0
                            
                            //Iterate through each participant.
                            for individualUser in returnedUsers
                            {
                                var mutableConversations: [String]?
                                
                                if let participatingIn = individualUser.conversationIdentifiers()
                                {
                                    mutableConversations = participatingIn
                                    mutableConversations?.append(generatedKey)
                                }
                                
                                GenericSerialiser().setValue(onKey: "/allUsers/\(individualUser.associatedIdentifier!)/participatingIn", withData: mutableConversations == nil ? [generatedKey] : mutableConversations!) { (wrappedError) in
                                    if let setValueError = wrappedError
                                    {
                                        if verboseFunctionExposure { print("Finished creating Conversation!") }
                                        
                                        completionHandler(nil, setValueError.localizedDescription)
                                    }
                                    
                                    amountProcessed += 1
                                    
                                    if amountProcessed == returnedUsers.count
                                    {
                                        if verboseFunctionExposure { print("Finished creating Conversation!") }
                                        
                                        completionHandler(generatedKey, nil)
                                    }
                                }
                            }
                        }
                        else
                        {
                            guard let getUsersErrors = wrappedErrorDescriptors else { if verboseFunctionExposure { print("Finished creating Conversation!") }; completionHandler(nil, "An unknown error occurred."); return }
                            
                            if verboseFunctionExposure { print("Finished creating Conversation!") }
                            
                            completionHandler(nil, getUsersErrors.joined(separator: "\n"))
                        }
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished creating Conversation!") }
            
            completionHandler(nil, "Unable to create key in database.")
        }
    }
    
    /**
     Attempts to get a **Conversation** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedConversation: The resulting **Conversation** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getConversation(withIdentifier: String, completionHandler: @escaping(_ returnedConversation: Conversation?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Conversation...") }
        
        Database.database().reference().child("allConversations").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                self.deSerialiseConversation(fromDataBundle: mutableDataBundle) { (wrappedConversation, deSerialiseErrorDescriptor) in
                    if let returnedConversation = wrappedConversation
                    {
                        if verboseFunctionExposure { print("Finished getting Conversation!") }
                        
                        completionHandler(returnedConversation, nil)
                    }
                    else
                    {
                        if verboseFunctionExposure { print("Finished getting Conversation!") }
                        
                        completionHandler(nil, deSerialiseErrorDescriptor!)
                    }
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting Conversation!") }
                
                completionHandler(nil, "No conversation exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting Conversation!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    /**
     Attempts to get **Conversations** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedConversations: The resulting **Conversations** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getConversations(withIdentifiers: [String], completionHandler: @escaping(_ returnedConversations: [Conversation]?, _ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Conversations...") }
        
        var conversationArray: [Conversation]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                getConversation(withIdentifier: individualIdentifier) { (wrappedConversation, wrappedErrorDescriptor) in
                    if let returnedConversation = wrappedConversation
                    {
                        conversationArray.append(returnedConversation)
                    }
                    else
                    {
                        errorDescriptorArray.append(wrappedErrorDescriptor!)
                    }
                    
                    if conversationArray.count + errorDescriptorArray.count == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished getting Conversations!") }
                        
                        completionHandler(conversationArray.count == 0 ? nil : conversationArray, errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished getting Conversations!") }
            
            completionHandler(nil, ["No identifiers passed!"])
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    private func deSerialiseConversation(fromDataBundle: [String:Any], completionHandler: @escaping(_ deSerialisedConversation: Conversation?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Deserialising Conversation...") }
        
        guard let associatedIdentifier     = fromDataBundle["associatedIdentifier"]     as? String   else { completionHandler(nil, "Unable to deserialise «associatedIdentifier»."); return }
        guard let associatedMessages       = fromDataBundle["associatedMessages"]       as? [String] else { completionHandler(nil, "Unable to deserialise «associatedMessages»."); return }
        guard let conversationParticipants = fromDataBundle["conversationParticipants"] as? [String] else { completionHandler(nil, "Unable to deserialise «conversationParticipants»."); return }
        guard let lastModified             = fromDataBundle["lastModified"]             as? String   else { completionHandler(nil, "Unable to deserialise «lastModified»."); return }
        
        if let fullyDeSerialisedLastModifiedDate = secondaryDateFormatter.date(from: lastModified)
        {
            MessageSerialiser().getMessages(withIdentifiers: associatedMessages) { (wrappedMessages, getMessagesErrorDescriptors) in
                if let returnedMessages = wrappedMessages
                {
                    if verboseFunctionExposure { print("Finished deserialising Conversation!") }
                    
                    let deSerialisedConversation = Conversation(associatedIdentifier: associatedIdentifier,
                                                                associatedMessages: returnedMessages,
                                                                lastModifiedDate: fullyDeSerialisedLastModifiedDate,
                                                                participantIdentifiers: conversationParticipants)
                    
                    completionHandler(deSerialisedConversation, nil)
                }
                else if let errorDescriptors = getMessagesErrorDescriptors
                {
                    if verboseFunctionExposure { print("Finished deserialising Conversation!") }
                    
                    completionHandler(nil, errorDescriptors.joined(separator: "\n"))
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished deserialising Conversation!") }
            
            completionHandler(nil, "Unable to convert «lastModified» to Date.")
        }
    }
}
