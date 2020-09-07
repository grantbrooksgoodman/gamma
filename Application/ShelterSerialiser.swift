//
//  ShelterSerialiser.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 14/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class ShelterSerialiser
{
    //--------------------------------------------------//
    
    /**
     Creates a **Shelter** on the server.
     
     - Parameter additionalImageData: Data for any additional images the **Shelter** would like to display.
     - Parameter associatedAddress: The **Shelter's** street address.
     - Parameter associatedBiography: A brief description of the **Shelter.**
     - Parameter businessName: The **Shelter's** name.
     - Parameter operatingHours: The **Shelter's** operating hours.
     - Parameter phoneNumber: The **Shelter's** phone number.
     - Parameter profileImageData: Data for the **Shelter's** profile image.
     
     - Parameter returnedIdentifier: The identifier of the new **Shelter** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createShelter(additionalImageData: [String]?, associatedAddress: String, associatedBiography: String?, businessName: String, operatingHours: String, phoneNumber: String, profileImageData: String?, completionHandler: @escaping(_ returnedIdentifier: String?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Creating Shelter...") }
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["additionalImageData"] = additionalImageData
        dataBundle["associatedAddress"]   = associatedAddress
        dataBundle["associatedBiography"] = associatedBiography
        dataBundle["businessName"]        = businessName
        dataBundle["operatingHours"]      = operatingHours
        dataBundle["phoneNumber"]         = phoneNumber
        dataBundle["profileImageData"]    = profileImageData
        
        if let generatedKey = Database.database().reference().child("/allShelters/").childByAutoId().key
        {
            GenericSerialiser().updateValue(onKey: "/allShelters/\(generatedKey)", withData: dataBundle) { (wrappedError) in
                if let returnedError = wrappedError
                {
                    if verboseFunctionExposure { print("Finished creating Shelter!") }
                    
                    completionHandler(nil, returnedError.localizedDescription)
                }
                else
                {
                    if verboseFunctionExposure { print("Finished creating Shelter!") }
                    
                    completionHandler(generatedKey, nil)
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished creating Shelter!") }
            
            completionHandler(nil, "Unable to create key in database.")
        }
    }
    
    /**
     Attempts to get a **Shelter** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedShelter: The resulting **Shelter** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getShelter(withIdentifier: String, completionHandler: @escaping(_ returnedShelter: Shelter?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Shelter...") }
        
        Database.database().reference().child("allShelters").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                self.deSerialiseShelter(fromDataBundle: mutableDataBundle) { (wrappedShelter, deSerialiseErrorDescriptor) in
                    if let returnedShelter = wrappedShelter
                    {
                        if verboseFunctionExposure { print("Finished getting Shelter!") }
                        
                        completionHandler(returnedShelter, nil)
                    }
                    else
                    {
                        if verboseFunctionExposure { print("Finished getting Shelter!") }
                        
                        completionHandler(nil, deSerialiseErrorDescriptor!)
                    }
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting Shelter!") }
                
                completionHandler(nil, "No shelter exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting Shelter!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    /**
     Attempts to get **Shelters** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedMessages: The resulting **Shelters** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getShelters(withIdentifiers: [String], completionHandler: @escaping(_ returnedShelters: [Shelter]?, _ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Shelters...") }
        
        var shelterArray: [Shelter]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                getShelter(withIdentifier: individualIdentifier) { (wrappedShelter, getShelterErrorDescriptor) in
                    if let returnedShelter = wrappedShelter
                    {
                        shelterArray.append(returnedShelter)
                    }
                    else
                    {
                        errorDescriptorArray.append(getShelterErrorDescriptor!)
                    }
                    
                    if shelterArray.count + errorDescriptorArray.count == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished getting Shelters!") }
                        
                        completionHandler(shelterArray.count == 0 ? nil : shelterArray, errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished getting Shelters!") }
            
            completionHandler(nil, ["No identifiers passed!"])
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    private func deSerialiseShelter(fromDataBundle: [String:Any], completionHandler: @escaping(_ deSerialisedSheleter: Shelter?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Deserialising Shelter...") }
        
        guard let additionalImageData = fromDataBundle["additionalImageData"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «additionalImageData»."); return }
        
        guard let associatedAddress = fromDataBundle["associatedAddress"] as? String
            else { completionHandler(nil, "Unable to deserialise «associatedAddress»."); return }
        
        guard let associatedBiography = fromDataBundle["associatedBiography"] as? String
            else { completionHandler(nil, "Unable to deserialise «associatedBiography»."); return }
        
        guard let associatedIdentifier = fromDataBundle["associatedIdentifier"] as? String
            else { completionHandler(nil, "Unable to deserialise «associatedIdentifier»."); return }
        
        guard let availableAnimalIdentifiers = fromDataBundle["availableAnimals"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «availableAnimals»."); return }
        
        guard let businessName = fromDataBundle["businessName"] as? String
            else { completionHandler(nil, "Unable to deserialise «businessName»."); return }
        
        guard let operatingHours = fromDataBundle["operatingHours"] as? String
            else { completionHandler(nil, "Unable to deserialise «operatingHours»."); return }
        
        guard let phoneNumber = fromDataBundle["phoneNumber"] as? String
            else { completionHandler(nil, "Unable to deserialise «phoneNumber»."); return }
        
        guard let profileImageData = fromDataBundle["profileImageData"] as? String
            else { completionHandler(nil, "Unable to deserialise «profileImageData»."); return }
        
        let deSerialisedShelter = Shelter(additionalImageData:        (additionalImageData == ["!"] ? nil : additionalImageData),
                                          associatedAddress:          associatedAddress,
                                          associatedBiography:        (associatedBiography == "!" ? nil : associatedBiography),
                                          associatedIdentifier:       associatedIdentifier,
                                          availableAnimalIdentifiers: (availableAnimalIdentifiers == ["!"] ? nil : availableAnimalIdentifiers),
                                          businessName:               businessName,
                                          operatingHours:             operatingHours,
                                          phoneNumber:                phoneNumber,
                                          profileImageData:           (profileImageData == "!" ? nil : profileImageData))
        
        if verboseFunctionExposure { print("Finished deserialising Shelter!") }
        
        completionHandler(deSerialisedShelter, nil)
    }
}
