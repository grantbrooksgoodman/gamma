//
//  Shelter.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 14/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class Shelter
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Array Declarations
    var additionalImageData:        [String]?
    var availableAnimalIdentifiers: [String]?
    
    //String Declarations
    var associatedAddress:    String!
    var associatedBiography:  String?
    var associatedIdentifier: String!
    var businessName:         String!
    var operatingHours:       String!
    var phoneNumber:          String!
    var profileImageData:     String?
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    init(additionalImageData: [String]?, associatedAddress: String, associatedBiography: String?, associatedIdentifier: String, availableAnimalIdentifiers: [String]?, businessName: String, operatingHours: String, phoneNumber: String, profileImageData: String?)
    {
        self.additionalImageData = additionalImageData
        self.associatedAddress = associatedAddress
        self.associatedBiography = associatedBiography
        self.associatedIdentifier = associatedIdentifier
        self.availableAnimalIdentifiers = availableAnimalIdentifiers
        self.businessName = businessName
        self.operatingHours = operatingHours
        self.phoneNumber = phoneNumber
        self.profileImageData = profileImageData
    }
    
    //--------------------------------------------------//
}
