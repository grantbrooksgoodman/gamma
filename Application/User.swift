//
//  UserObject.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class User
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Array Variables
    var livingSpaceImageData:     [String]?
    var matchedAnimalIdentifiers: [String]?
    var swipedOnIdentifiers:      [String]?
    var participatingIn:          [Conversation]?
    
    //String Variables
    var associatedBiography:  String!
    var associatedIdentifier: String!
    var emailAddress:         String!
    var firstName:            String!
    var lastName:             String!
    var phoneNumber:          String!
    var profileImageData:     String?
    
    //Other Variables
    var associatedInterview: Interview!
    var birthDate: Date!
    var zipCode: Int!
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    init(associatedBiography: String, associatedIdentifier: String, associatedInterview: Interview, birthDate: Date, emailAddress: String, firstName: String, lastName: String, livingSpaceImageData: [String]?, matchedAnimalIdentifiers: [String]?, participatingIn: [Conversation]?, phoneNumber: String, profileImageData: String?, swipedOnIdentifiers: [String]?, zipCode: Int)
    {
        self.associatedBiography      = associatedBiography
        self.associatedIdentifier     = associatedIdentifier
        self.associatedInterview      = associatedInterview
        self.birthDate                = birthDate
        self.emailAddress             = emailAddress
        self.firstName                = firstName
        self.lastName                 = lastName
        self.livingSpaceImageData     = livingSpaceImageData
        self.matchedAnimalIdentifiers = matchedAnimalIdentifiers
        self.participatingIn          = participatingIn
        self.phoneNumber              = phoneNumber
        self.profileImageData         = profileImageData
        self.swipedOnIdentifiers      = swipedOnIdentifiers
        self.zipCode                  = zipCode
    }
    
    //--------------------------------------------------//
    
    //Public Functions
    
    func conversationIdentifiers() -> [String]?
    {
        if let unwrappedParticipatingIn = participatingIn
        {
            var identifierArray: [String]! = []
            
            for individualConversation in unwrappedParticipatingIn
            {
                identifierArray.append(individualConversation.associatedIdentifier)
                
                if unwrappedParticipatingIn.count == identifierArray.count
                {
                    return identifierArray
                }
            }
        }
        
        return nil
    }
}
