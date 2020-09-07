//
//  Animal.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 29/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class Animal
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Arrays
    var associatedImageData:    [String]?
    var matchedUserIdentifiers: [String]?
    var participatingIn:        [Conversation]?
    
    //Booleans
    var goodWithChildren: Bool!
    var isMale:           Bool!
    var isVaccinated:     Bool!
    
    //Doubles
    var ageInWeeks:     Double!
    var weightInPounds: Double!
    
    //Integers
    var hasBeenNeutered: Int!
    
    //Strings
    var animalName:                  String!
    var animalType:                  String!
    var associatedBiography:         String!
    var associatedIdentifier:        String!
    var associatedShelterIdentifier: String!
    var breedType:                   String!
    var generalColour:               String!
    var shelterComments:             String!
    var specialNotes:                String?
    
    //Other Declarations
    var dateProcessed: Date!
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    init(ageInWeeks: Double,
         animalName: String,
         animalType: String,
         associatedBiography: String,
         associatedIdentifier: String,
         associatedImageData: [String]?,
         associatedShelterIdentifier: String,
         breedType: String,
         dateProcessed: Date,
         generalColour: String,
         goodWithChildren: Bool,
         hasBeenNeutered: Int,
         isMale: Bool,
         isVaccinated: Bool,
         matchedUserIdentifiers: [String]?,
         participatingIn: [Conversation]?,
         shelterComments: String,
         specialNotes: String?,
         weightInPounds: Double)
    {
        self.ageInWeeks                  = ageInWeeks
        self.animalName                  = animalName
        self.animalType                  = animalType
        self.associatedBiography         = associatedBiography
        self.associatedIdentifier        = associatedIdentifier
        self.associatedImageData         = associatedImageData
        self.associatedShelterIdentifier = associatedShelterIdentifier
        self.breedType                   = breedType
        self.dateProcessed               = dateProcessed
        self.generalColour               = generalColour
        self.goodWithChildren            = goodWithChildren
        self.hasBeenNeutered             = hasBeenNeutered
        self.isMale                      = isMale
        self.isVaccinated                = isVaccinated
        self.matchedUserIdentifiers      = matchedUserIdentifiers
        self.participatingIn             = participatingIn
        self.shelterComments             = shelterComments
        self.specialNotes                = specialNotes
        self.weightInPounds              = weightInPounds
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
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
    
    ///Serialises the **Animal's** metadata.
    func convertToDataBundle() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        dataBundle["ageInWeeks"]                  = ageInWeeks
        dataBundle["animalName"]                  = animalName
        dataBundle["animalType"]                  = animalType
        dataBundle["associatedBiography"]         = associatedBiography
        dataBundle["associatedIdentifier"]        = associatedIdentifier
        dataBundle["associatedImageData"]         = associatedImageData ?? ["!"]
        dataBundle["associatedShelter"]           = associatedShelterIdentifier
        dataBundle["breedType"]                   = breedType
        dataBundle["dateProcessed"]               = masterDateFormatter.string(from: dateProcessed)
        dataBundle["generalColour"]               = generalColour
        dataBundle["goodWithChildren"]            = goodWithChildren
        dataBundle["hasBeenNeutered"]             = hasBeenNeutered
        dataBundle["isMale"]                      = isMale
        dataBundle["isVaccinated"]                = isVaccinated
        dataBundle["matchedUsers"]                = matchedUserIdentifiers ?? ["!"]
        dataBundle["participatingIn"]             = conversationIdentifiers() ?? ["!"]
        dataBundle["shelterComments"]             = shelterComments
        dataBundle["specialNotes"]                = specialNotes ?? "!"
        dataBundle["weightInPounds"]              = weightInPounds
        
        return dataBundle
    }
}
