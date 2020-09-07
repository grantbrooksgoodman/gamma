//
//  Interview.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 27/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class Interview
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Array Declarations
    var lifestyleTraits: [String]! = []
    var otherPets:       [String]?
    
    //Integer Declarations
    var confidenceLevel:  Int!
    var employmentStatus: Int!
    var livingSituation:  Int!
    
    //Other Declarations
    var employmentStatusExplanation: String?
    var livingSituationExplanation:  String?
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    init(confidenceLevel: Int, employmentStatus: Int, employmentStatusExplanation: String?, lifestyleTraits: [String], livingSituation: Int, livingSituationExplanation: String?, otherPets: [String]?)
    {
        self.confidenceLevel             = confidenceLevel
        self.employmentStatus            = employmentStatus
        self.employmentStatusExplanation = employmentStatusExplanation
        self.lifestyleTraits             = lifestyleTraits
        self.livingSituation             = livingSituation
        self.livingSituationExplanation  = livingSituationExplanation
        self.otherPets                   = otherPets
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    ///Serialises the **Interview's** metadata.
    func convertToDataBundle() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        dataBundle["confidenceLevel"]  = confidenceLevel
        dataBundle["employmentStatus"] = (employmentStatus == 3 ? employmentStatusExplanation! : employmentStatus)
        dataBundle["lifestyleTraits"]  = lifestyleTraits
        dataBundle["livingSituation"]  = (livingSituation == 3 ? livingSituationExplanation! : livingSituation)
        dataBundle["otherPets"]        = otherPets ?? ["!"]
        
        return dataBundle
    }
}
