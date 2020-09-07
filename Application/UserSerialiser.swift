//
//  UserSerialiser.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class UserSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    /**
     Creates a **User** on the server with a provided identifier.
     
     - Parameter associatedBiography: A brief description of the **User.**
     - Parameter associatedIdentifier: The identifier to create the **User** with.
     - Parameter associatedInterview: The **Interview** taken by the **User.**
     - Parameter birthDate: The **User's** birth date.
     - Parameter emailAddress: The **User's** e-mail address.
     - Parameter firstName: The **User's** first name.
     - Parameter lastName: The **User's** last name.
     - Parameter livingSpaceImageData: Data for any images of the **User's** living space that they would like to display.
     - Parameter phoneNumber: The **User's** phone number.
     - Parameter profileImageData: Data for the **User's** profile image.
     - Parameter zipCode: The **User's** ZIP code.
     
     - Parameter returnedUser: The resulting **User** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createUser(associatedBiography: String, associatedIdentifier: String, associatedInterview: Interview, birthDate: Date, emailAddress: String, firstName: String, lastName: String, livingSpaceImageData: [String]?, phoneNumber: String, profileImageData: String?, zipCode: Int, completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Creating User...") }
        
        let transformedFirstName = firstName
        CFStringTransform((transformedFirstName as! CFMutableString), nil, kCFStringTransformToLatin, false)
        CFStringTransform((transformedFirstName as! CFMutableString), nil, kCFStringTransformStripCombiningMarks, false)
        
        let transformedLastName = lastName
        CFStringTransform((transformedLastName as! CFMutableString), nil, kCFStringTransformToLatin, false)
        CFStringTransform((transformedLastName as! CFMutableString), nil, kCFStringTransformStripCombiningMarks, false)
        
        let birthDateString = masterDateFormatter.string(from: birthDate)
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["associatedBiography"]  = associatedBiography
        dataBundle["interviewQuestions"]   = associatedInterview.convertToDataBundle()
        dataBundle["birthDate"]            = birthDateString
        dataBundle["emailAddress"]         = emailAddress
        dataBundle["firstName"]            = transformedFirstName
        dataBundle["lastName"]             = transformedLastName
        dataBundle["livingSpaceImageData"] = livingSpaceImageData ?? ["!"]
        dataBundle["matchedAnimals"]       = ["!"]
        dataBundle["participatingIn"]      = ["!"]
        dataBundle["phoneNumber"]          = phoneNumber
        dataBundle["profileImageData"]     = profileImageData ?? "!"
        dataBundle["swipedOn"]             = ["!"]
        dataBundle["zipCode"]              = zipCode
        
        GenericSerialiser().updateValue(onKey: "/allUsers/\(associatedIdentifier)", withData: dataBundle) { (wrappedError) in
            if let returnedError = wrappedError
            {
                if verboseFunctionExposure { print("Finished creating User!") }
                
                completionHandler(nil, errorInformation(forError: returnedError as NSError))
            }
            else
            {
                if verboseFunctionExposure { print("Finished creating User!") }
                
                completionHandler(User(associatedBiography: associatedIdentifier, associatedIdentifier: associatedIdentifier, associatedInterview: associatedInterview, birthDate: birthDate, emailAddress: emailAddress, firstName: firstName, lastName: lastName, livingSpaceImageData: livingSpaceImageData, matchedAnimalIdentifiers: nil, participatingIn: nil, phoneNumber: phoneNumber, profileImageData: profileImageData, swipedOnIdentifiers: nil, zipCode: zipCode), nil)
            }
        }
    }
    
    /**
     Attempts to get a **User** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedUser: The resulting **User** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getUser(withIdentifier: String, completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting User...") }
        
        Database.database().reference().child("allUsers").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                self.deSerialiseUser(fromDataBundle: mutableDataBundle) { (wrappedUser, wrappedErrorDescriptor) in
                    if verboseFunctionExposure { print("Finished getting User!") }
                    
                    completionHandler((wrappedErrorDescriptor != nil ? nil : wrappedUser), wrappedErrorDescriptor)
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting User!") }
                
                completionHandler(nil, "No user exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting User!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    /**
     Attempts to get **Users** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedUsers: The resulting **Users** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getUsers(withIdentifiers: [String], completionHandler: @escaping(_ returnedUsers: [User]?, _ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Users...") }
        
        var userArray: [User]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                getUser(withIdentifier: individualIdentifier) { (wrappedUser, wrappedErrorDescriptor) in
                    if let returnedUser = wrappedUser
                    {
                        userArray.append(returnedUser)
                    }
                    else
                    {
                        errorDescriptorArray.append(wrappedErrorDescriptor!)
                    }
                    
                    if userArray.count + errorDescriptorArray.count == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished getting Users!") }
                        
                        completionHandler(userArray.count == 0 ? nil : userArray, errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished getting Users!") }
            
            completionHandler(nil, ["No identifiers passed!"])
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    ////Converts a data bundle into an **Interview** object.
    private func deSerialiseInterview(fromDataBundle: [String:Any]) -> Interview?
    {
        if verboseFunctionExposure { print("Deserialising the Interview...") }
        
        if let confidenceLevel   = fromDataBundle["confidenceLevel"]  as? Int,
            let lifestyleTraits  = fromDataBundle["lifestyleTraits"]  as? [String],
            let otherPets        = fromDataBundle["otherPets"]        as? [String]
        {
            if let employmentStatus = fromDataBundle["employmentStatus"] as? Int
            {
                if let livingSituation = fromDataBundle["livingSituation"]  as? Int
                {
                    if verboseFunctionExposure { print("Finished deserialising the Interview!") }
                    
                    return Interview(confidenceLevel: confidenceLevel, employmentStatus: employmentStatus, employmentStatusExplanation: nil, lifestyleTraits: lifestyleTraits, livingSituation: livingSituation, livingSituationExplanation: nil, otherPets: otherPets)
                }
                else if let livingSituationExplanation = fromDataBundle["livingSituation"] as? String
                {
                    if verboseFunctionExposure { print("Finished deserialising the Interview!") }
                    
                    return Interview(confidenceLevel: confidenceLevel, employmentStatus: employmentStatus, employmentStatusExplanation: nil, lifestyleTraits: lifestyleTraits, livingSituation: 3, livingSituationExplanation: livingSituationExplanation, otherPets: otherPets)
                }
            }
            else if let employmentStatusExplanation = fromDataBundle["employmentStatus"] as? String
            {
                if let livingSituation = fromDataBundle["livingSituation"]  as? Int
                {
                    if verboseFunctionExposure { print("Finished deserialising the Interview!") }
                    
                    return Interview(confidenceLevel: confidenceLevel, employmentStatus: 3, employmentStatusExplanation: employmentStatusExplanation, lifestyleTraits: lifestyleTraits, livingSituation: livingSituation, livingSituationExplanation: nil, otherPets: otherPets)
                }
                else if let livingSituationExplanation = fromDataBundle["livingSituation"] as? String
                {
                    if verboseFunctionExposure { print("Finished deserialising the Interview!") }
                    
                    return Interview(confidenceLevel: confidenceLevel, employmentStatus: 3, employmentStatusExplanation: employmentStatusExplanation, lifestyleTraits: lifestyleTraits, livingSituation: 3, livingSituationExplanation: livingSituationExplanation, otherPets: otherPets)
                }
            }
        }
        
        return nil
    }
    
    private func deSerialiseUser(fromDataBundle: [String:Any], completionHandler: @escaping(_ deSerialisedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Deserialising the User...") }
        
        guard let associatedIdentifier     = fromDataBundle["associatedIdentifier"]  as? String       else { completionHandler(nil, "Unable to deserialise «associatedIdentifier»."); return }
        guard let associatedBiography      = fromDataBundle["associatedBiography"]   as? String       else { completionHandler(nil, "Unable to deserialise «associatedBiography»."); return }
        guard let associatedInterview      = fromDataBundle["interviewQuestions"]    as? [String:Any] else { completionHandler(nil, "Unable to deserialise «interviewQuestions»."); return }
        guard let birthDate                = fromDataBundle["birthDate"]             as? String       else { completionHandler(nil, "Unable to deserialise «birthDate»."); return }
        guard let emailAddress             = fromDataBundle["emailAddress"]          as? String       else { completionHandler(nil, "Unable to deserialise «emailAddress»."); return }
        guard let firstName                = fromDataBundle["firstName"]             as? String       else { completionHandler(nil, "Unable to deserialise «firstName»."); return }
        guard let lastName                 = fromDataBundle["lastName"]              as? String       else { completionHandler(nil, "Unable to deserialise «lastName»."); return }
        guard let livingSpaceImageData     = fromDataBundle["livingSpaceImageData"]  as? [String]     else { completionHandler(nil, "Unable to deserialise «livingSpaceImageData»."); return }
        guard let matchedAnimalIdentifiers = fromDataBundle["matchedAnimals"]        as? [String]     else { completionHandler(nil, "Unable to deserialise «matchedAnimals»."); return }
        guard let participatingIn          = fromDataBundle["participatingIn"]       as? [String]     else { completionHandler(nil, "Unable to deserialise «participatingIn»."); return }
        guard let phoneNumber              = fromDataBundle["phoneNumber"]           as? String       else { completionHandler(nil, "Unable to deserialise «phoneNumber»."); return }
        guard let profileImageData         = fromDataBundle["profileImageData"]      as? String       else { completionHandler(nil, "Unable to deserialise «profileImageData»."); return }
        guard let swipedOnIdentifiers      = fromDataBundle["swipedOn"]              as? [String]     else { completionHandler(nil, "Unable to deserialise «swipedOnIdentifiers»."); return }
        guard let zipCode                  = fromDataBundle["zipCode"]               as? Int          else { completionHandler(nil, "Unable to deserialise «zipCode»."); return }
        
        if let fullyDeSerialisedBirthDate = masterDateFormatter.date(from: birthDate)
        {
            if let fullyDeSerialisedInterview = UserSerialiser().deSerialiseInterview(fromDataBundle: associatedInterview)
            {
                let deSerialisedUser = User(associatedBiography:      associatedBiography,
                                            associatedIdentifier:     associatedIdentifier,
                                            associatedInterview:      fullyDeSerialisedInterview,
                                            birthDate:                fullyDeSerialisedBirthDate,
                                            emailAddress:             emailAddress,
                                            firstName:                firstName,
                                            lastName:                 lastName,
                                            livingSpaceImageData:     livingSpaceImageData,
                                            matchedAnimalIdentifiers: (matchedAnimalIdentifiers == ["!"] ? nil : matchedAnimalIdentifiers),
                                            participatingIn:          nil,
                                            phoneNumber:              phoneNumber,
                                            profileImageData:         (profileImageData == "!" ? nil : profileImageData),
                                            swipedOnIdentifiers:      swipedOnIdentifiers,
                                            zipCode:                  zipCode)
                
                if participatingIn != ["!"]
                {
                    ConversationSerialiser().getConversations(withIdentifiers: participatingIn) { (wrappedConversations, getConversationsErrorDescriptors) in
                        if let returnedConversations = wrappedConversations
                        {
                            //if a user has a conversation, that means they have a match already. it must.
                            deSerialisedUser.participatingIn = returnedConversations
                            
                            if verboseFunctionExposure { print("Finished deserialising the User!") }
                            
                            completionHandler(deSerialisedUser, nil)
                        }
                        else if let errorDescriptors = getConversationsErrorDescriptors
                        {
                            if verboseFunctionExposure { print("Finished deserialising the User!") }
                            
                            completionHandler(nil, errorDescriptors.joined(separator: "\n"))
                        }
                    }
                }
                else
                {
                    if verboseFunctionExposure { print("Finished deserialising the User!") }
                    
                    completionHandler(deSerialisedUser, nil)
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished deserialising the User!") }
                
                completionHandler(nil, "Unable to convert «associatedInterview» to Interview.")
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished deserialising the User!") }
            
            completionHandler(nil, "Unable to convert «birthDate» to Date.")
        }
    }
}
