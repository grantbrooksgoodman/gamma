//
//  AnimalSerialiser.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 02/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class AnimalSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    /**
     Creates an **Animal** on the server.
     
     - Parameter ageInWeeks: The **Animal's** age in weeks.
     - Parameter animalName: The **Animal's** name.
     - Parameter animalType: The **Animal's** type, e.g. "cat" or "dog".
     - Parameter associatedBiography: The Tinder-style biography for the **Animal.**
     - Parameter associatedImageData: The image data associated with the **Animal.**
     - Parameter associatedShelterIdentifier: The **Animal's** **Shelter** identifier String.
     - Parameter breedType: The **Animal's** breed, e.g. "terrier".
     - Parameter dateProcessed: The date that the **Animal** was processed into its **Shelter.**
     - Parameter generalColour: The general colour of the **Animal.**
     - Parameter goodWithChildren: A Boolean representing whether or not the **Animal** is good with children.
     - Parameter hasBeenNeutered: 0 = not neutered, 1 = neutered, and 2 = not applicable.
     - Parameter isMale: A Boolean representing the gender of the **Animal.**
     - Parameter isVaccinated: A Boolean representing whether or not the **Animal** has been vaccinated.
     - Parameter shelterComments: The **Shelter's** comments about the **Animal.**
     - Parameter specialNotes: Any special notes prospective adopters need to know about the **Animal.**
     - Parameter weightInPounds: The **Animal's** weight in pounds.
     
     - Parameter returnedAnimal: The resulting **Animal** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createAnimal(ageInWeeks: Double,
                      animalName: String,
                      animalType: String,
                      associatedBiography: String, 
                      associatedImageData: [String]?,
                      associatedShelterIdentifier: String,
                      breedType: String,
                      dateProcessed: Date,
                      generalColour: String,
                      goodWithChildren: Bool,
                      hasBeenNeutered: Int,
                      isMale: Bool,
                      isVaccinated: Bool,
                      shelterComments: String,
                      specialNotes: String?,
                      weightInPounds: Double,
                      completionHandler: @escaping(_ returnedAnimal: Animal?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Creating Animal...") }
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["ageInWeeks"]                  = ageInWeeks
        dataBundle["animalName"]                  = animalName
        dataBundle["animalType"]                  = animalType
        dataBundle["associatedBiography"]         = associatedBiography
        dataBundle["associatedImageData"]         = associatedImageData ?? ["!"]
        dataBundle["associatedShelter"]           = associatedShelterIdentifier
        dataBundle["breedType"]                   = breedType
        dataBundle["dateProcessed"]               = masterDateFormatter.string(from: dateProcessed)
        dataBundle["generalColour"]               = generalColour
        dataBundle["goodWithChildren"]            = goodWithChildren
        dataBundle["hasBeenNeutered"]             = hasBeenNeutered
        dataBundle["isMale"]                      = isMale
        dataBundle["isVaccinated"]                = isVaccinated
        dataBundle["matchedUsers"]                = ["!"]
        dataBundle["participatingIn"]             = ["!"]
        dataBundle["shelterComments"]             = shelterComments
        dataBundle["specialNotes"]                = specialNotes ?? "!"
        dataBundle["weightInPounds"]              = weightInPounds
        
        if let generatedKey = Database.database().reference().child("/allAnimals/").childByAutoId().key
        {
            GenericSerialiser().updateValue(onKey: "/allAnimals/\(generatedKey)", withData: dataBundle) { (wrappedError) in
                if let returnedError = wrappedError
                {
                    if verboseFunctionExposure { print("Finished creating Animal!") }
                    
                    completionHandler(nil, returnedError.localizedDescription)
                }
                else
                {
                    if verboseFunctionExposure { print("Finished creating Animal!") }
                    
                    completionHandler(Animal(ageInWeeks:                  ageInWeeks,
                                             animalName:                  animalName,
                                             animalType:                  animalName,
                                             associatedBiography:         associatedBiography,
                                             associatedIdentifier:        generatedKey,
                                             associatedImageData:         associatedImageData,
                                             associatedShelterIdentifier: associatedShelterIdentifier,
                                             breedType:                   breedType,
                                             dateProcessed:               dateProcessed,
                                             generalColour:               generalColour,
                                             goodWithChildren:            goodWithChildren,
                                             hasBeenNeutered:             hasBeenNeutered,
                                             isMale:                      isMale,
                                             isVaccinated:                isVaccinated,
                                             matchedUserIdentifiers:      nil,
                                             participatingIn:             nil,
                                             shelterComments:             shelterComments,
                                             specialNotes:                specialNotes,
                                             weightInPounds:              weightInPounds), nil)
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished creating Animal!") }
            
            completionHandler(nil, "Unable to create key in database.")
        }
    }
    
    func getRandomAnimals(amountToGet: Int?, completionHandler: @escaping(_ returnedAnimalIdentifiers: [String]?, _ noticeDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting random Animal...") }
        
        Database.database().reference().child("allAnimals").observeSingleEvent(of: .value) { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary,
                let animalIdentifierArray = returnedSnapshotAsDictionary.allKeys as? [String]
            {
                if amountToGet == nil
                {
                    completionHandler(animalIdentifierArray.shuffledValue, nil)
                }
                else
                {
                    if amountToGet! > animalIdentifierArray.count
                    {
                        completionHandler(animalIdentifierArray.shuffledValue, "Requested amount was larger than database size.")
                    }
                    else if amountToGet! == animalIdentifierArray.count
                    {
                        completionHandler(animalIdentifierArray.shuffledValue, nil)
                    }
                    else if amountToGet! < animalIdentifierArray.count
                    {
                        completionHandler(Array(animalIdentifierArray.shuffledValue[0...amountToGet!]), nil)
                    }
                }
            }
            else
            {
                completionHandler(nil, "Unable to deserialise snapshot.")
            }
        }
    }
    
    /**
     Attempts to get an **Animal** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedAnimal: The resulting **Animal** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getAnimal(withIdentifier: String, completionHandler: @escaping(_ returnedAnimal: Animal?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Animal...") }
        
        Database.database().reference().child("allAnimals").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                self.deSerialiseAnimal(fromDataBundle: mutableDataBundle) { (wrappedAnimal, wrappedErrorDescriptor) in
                    if verboseFunctionExposure { print("Finished getting Animal!") }
                    
                    completionHandler((wrappedErrorDescriptor != nil ? nil : wrappedAnimal), wrappedErrorDescriptor)
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting Animal!") }
                
                completionHandler(nil, "No animal exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting Animal!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    /**
     Attempts to get **Animals** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedAnimals: The resulting **Animals** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getAnimals(withIdentifiers: [String], completionHandler: @escaping(_ returnedAnimals: [Animal]?, _ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Animals...") }
        
        var animalArray: [Animal]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                getAnimal(withIdentifier: individualIdentifier) { (wrappedAnimal, wrappedErrorDescriptor) in
                    if let returnedAnimal = wrappedAnimal
                    {
                        animalArray.append(returnedAnimal)
                    }
                    else
                    {
                        errorDescriptorArray.append(wrappedErrorDescriptor!)
                    }
                    
                    if animalArray.count + errorDescriptorArray.count == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished getting Animals!") }
                        
                        completionHandler(animalArray.count == 0 ? nil : animalArray, errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished getting Animals!") }
            
            completionHandler(nil, ["No identifiers passed!"])
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    private func deSerialiseAnimal(fromDataBundle: [String:Any], completionHandler: @escaping(_ deSerialisedAnimal: Animal?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Deserialising Animal...") }
        
        guard let ageInWeeks = fromDataBundle["ageInWeeks"]                                   as? Double   else { completionHandler(nil, "Unable to deserialise «ageInWeeks»."); return}
        guard let animalName = fromDataBundle["animalName"]                                   as? String   else { completionHandler(nil, "Unable to deserialise «animalName»."); return }
        guard let animalType = fromDataBundle["animalType"]                                   as? String   else { completionHandler(nil, "Unable to deserialise «animalType»."); return }
        guard let associatedIdentifier = fromDataBundle["associatedIdentifier"]               as? String   else { completionHandler(nil, "Unable to deserialise «associatedIdentifier»."); return }
        guard let associatedBiography = fromDataBundle["associatedBiography"]                 as? String   else { completionHandler(nil, "Unable to deserialise «associatedBiography»."); return }
        guard let associatedImageData = fromDataBundle["associatedImageData"]                 as? [String] else { completionHandler(nil, "Unable to deserialise «associatedImageData»."); return }
        guard let associatedShelterIdentifier = fromDataBundle["associatedShelter"]           as? String   else { completionHandler(nil, "Unable to deserialise «associatedShelter»."); return }
        guard let breedType = fromDataBundle["breedType"]                                     as? String   else { completionHandler(nil, "Unable to deserialise «breedType»."); return }
        guard let dateProcessed = fromDataBundle["dateProcessed"]                             as? String   else { completionHandler(nil, "Unable to deserialise «dateProcessed»."); return }
        guard let generalColour = fromDataBundle["generalColour"]                             as? String   else { completionHandler(nil, "Unable to deserialise «generalColour»."); return }
        guard let goodWithChildren = fromDataBundle["goodWithChildren"]                       as? Bool     else { completionHandler(nil, "Unable to deserialise «goodWithChildren»."); return }
        guard let hasBeenNeutered = fromDataBundle["hasBeenNeutered"]                         as? Int      else { completionHandler(nil, "Unable to deserialise «hasBeenNeutered»."); return }
        guard let isMale = fromDataBundle["isMale"]                                           as? Bool     else { completionHandler(nil, "Unable to deserialise «isMale»."); return }
        guard let isVaccinated = fromDataBundle["isVaccinated"]                               as? Bool     else { completionHandler(nil, "Unable to deserialise «isVaccinated»."); return }
        guard let matchedUserIdentifiers = fromDataBundle["matchedUsers"]                     as? [String] else { completionHandler(nil, "Unable to deserialise «matchedUsers»."); return }
        guard let participatingIn = fromDataBundle["participatingIn"]                         as? [String] else { completionHandler(nil, "Unable to deserialise «participatingIn»."); return }
        guard let shelterComments = fromDataBundle["shelterComments"]                         as? String   else { completionHandler(nil, "Unable to deserialise «shelterComments»."); return }
        guard let specialNotes = fromDataBundle["specialNotes"]                               as? String   else { completionHandler(nil, "Unable to deserialise «specialNotes»."); return }
        guard let weightInPounds = fromDataBundle["weightInPounds"]                           as? Double   else { completionHandler(nil, "Unable to deserialise «weightInPounds»."); return }
        
        if let fullyDeSerialisedDateProcessed = masterDateFormatter.date(from: dateProcessed)
        {
            if participatingIn != ["!"]
            {
                ConversationSerialiser().getConversations(withIdentifiers: participatingIn) { (wrappedConversations, getConversationsErrorDescriptors) in
                    if let returnedConversations = wrappedConversations
                    {
                        let deSerialisedAnimal = Animal(ageInWeeks:                 ageInWeeks,
                                                        animalName:                 animalName,
                                                        animalType:                 animalType,
                                                        associatedBiography:        associatedBiography,
                                                        associatedIdentifier:       associatedIdentifier,
                                                        associatedImageData:        (associatedImageData == ["!"] ? nil : associatedImageData),
                                                        associatedShelterIdentifier: associatedShelterIdentifier,
                                                        breedType:                   breedType,
                                                        dateProcessed:               fullyDeSerialisedDateProcessed,
                                                        generalColour:               generalColour,
                                                        goodWithChildren:            goodWithChildren,
                                                        hasBeenNeutered:             hasBeenNeutered,
                                                        isMale:                      isMale,
                                                        isVaccinated:                isVaccinated,
                                                        matchedUserIdentifiers:      (matchedUserIdentifiers == ["!"] ? nil : matchedUserIdentifiers),
                                                        participatingIn:             returnedConversations,
                                                        shelterComments:             shelterComments,
                                                        specialNotes:                (specialNotes == "!" ? nil : specialNotes),
                                                        weightInPounds:              weightInPounds)
                        
                        if verboseFunctionExposure { print("Finished deserialising Animal!") }
                        
                        completionHandler(deSerialisedAnimal, nil)
                    }
                    else if let errorDescriptors = getConversationsErrorDescriptors
                    {
                        if verboseFunctionExposure { print("Finished deserialising Animal!") }
                        
                        completionHandler(nil, errorDescriptors.joined(separator: "\n"))
                    }
                    else
                    {
                        completionHandler(nil, "An error occurred getting the Conversations.")
                    }
                }
            }
            else
            {
                let deSerialisedAnimal = Animal(ageInWeeks:                 ageInWeeks,
                                                animalName:                 animalName,
                                                animalType:                 animalType,
                                                associatedBiography:        associatedBiography,
                                                associatedIdentifier:       associatedIdentifier,
                                                associatedImageData:        (associatedImageData == ["!"] ? nil : associatedImageData),
                                                associatedShelterIdentifier: associatedShelterIdentifier,
                                                breedType:                   breedType,
                                                dateProcessed:               fullyDeSerialisedDateProcessed,
                                                generalColour:               generalColour,
                                                goodWithChildren:            goodWithChildren,
                                                hasBeenNeutered:             hasBeenNeutered,
                                                isMale:                      isMale,
                                                isVaccinated:                isVaccinated,
                                                matchedUserIdentifiers:      (matchedUserIdentifiers == ["!"] ? nil : matchedUserIdentifiers),
                                                participatingIn:             nil,
                                                shelterComments:             shelterComments,
                                                specialNotes:                (specialNotes == "!" ? nil : specialNotes),
                                                weightInPounds:              weightInPounds)
                
                if verboseFunctionExposure { print("Finished deserialising Animal!") }
                
                completionHandler(deSerialisedAnimal, nil)
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished deserialising Animal!") }
            
            completionHandler(nil, "Unable to convert «birthDate» to Date.")
        }
    }
}
