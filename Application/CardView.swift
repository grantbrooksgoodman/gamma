//
//  CardView.swift
//  Gamma
//
//  Created by Grant Brooks Goodman on 17/07/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class CardView: UIView
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UILabels
    @IBOutlet weak var nameLabel:     UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var informationButton: ShadowButton!
    @IBOutlet weak var photoPageControl: UIPageControl!
    @IBOutlet weak var profileImageView: UIImageView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    var informationView: InformationView!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func draw(_ rect: CGRect)
    {
        informationView = Bundle.main.loadNibNamed("InformationView", owner: self, options: nil)?[0] as? InformationView
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func informationButton(_ sender: Any)
    {
        informationView.alpha = 0
        
        if let cardController = self.superview?.parentViewController as? CardController
        {
            cardController.kolodaView.isUserInteractionEnabled = false
            
            let currentAnimal = cardController.animalArray[cardController.kolodaView.currentCardIndex]
            
            if informationView.nameLabel.text != currentAnimal.animalName.uppercased()
            {
                ShelterSerialiser().getShelter(withIdentifier: currentAnimal.associatedShelterIdentifier) { (wrappedShelter, getShelterError) in
                    if let returnedShelter = wrappedShelter
                    {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        dateFormatter.locale = Locale(identifier: "en_GB")
                        
                        self.informationView.nameLabel.text = currentAnimal.animalName.uppercased()
                        self.informationView.biographyTextView.text = currentAnimal.associatedBiography
                        self.informationView.subtitleLabel.useText("\(currentAnimal.isMale ? "Male, " : "Female, ")\(Int(currentAnimal.ageInWeeks))wks.") ; #warning ("Handle age in a better way.")
                        
                        if let imageDataArray = currentAnimal.associatedImageData,
                            let imageData = Data(base64Encoded: imageDataArray[0], options: .ignoreUnknownCharacters)
                        {
                            if let noImageLabel = self.informationView.profileImageView.findSubview(aTagFor("noImageLabel"))
                            {
                                noImageLabel.removeFromSuperview()
                            }
                            
                            self.informationView.profileImageView.image = UIImage(data: imageData)
                        }
                        else
                        {
                            self.informationView.profileImageView.image = nil
                            
                            let noImageLabel = UILabel(frame: f.frame(CGRect(x: 0, y: 0, width: 100, height: 20)))
                            noImageLabel.center = self.informationView.profileImageView.center
                            noImageLabel.font = UIFont(name: "SFUIText-Semibold", size: 12)
                            noImageLabel.tag = aTagFor("noImageLabel")
                            noImageLabel.text = "No Image"
                            noImageLabel.textAlignment = .center
                            noImageLabel.textColor = .lightGray
                            
                            self.informationView.addSubview(noImageLabel)
                            self.informationView.bringSubviewToFront(noImageLabel)
                        }
                        
                        self.informationView.toggleCheckmark(self.informationView.goodWithKidsRadioView, isChecked: currentAnimal.goodWithChildren)
                        self.informationView.toggleCheckmark(self.informationView.neuteredRadioView, isChecked: (currentAnimal.hasBeenNeutered == 0 ? false : true)) //IF 2 DO N/A
                        self.informationView.toggleCheckmark(self.informationView.vaccinatedRadioView, isChecked: currentAnimal.isVaccinated)
                        
                        self.informationView.breedLabel.useText(currentAnimal.breedType)
                        self.informationView.colourLabel.useText(currentAnimal.generalColour)
                        self.informationView.weightLabel.text = "\(Int(currentAnimal.weightInPounds))lbs."; #warning ("Fix Int(")
                        
                        self.informationView.ancillaryLabel.useText("\(currentAnimal.animalName!) joined \(returnedShelter.businessName!) on \(dateFormatter.string(from: currentAnimal.dateProcessed)).")
                        
                        self.informationView.commentsTextView.text = currentAnimal.shelterComments
                        
                        lastInitialisedController.view.addSubview(self.informationView)
                        lastInitialisedController.view.bringSubviewToFront(self.informationView)
                        
                        self.informationView.center = lastInitialisedController.view.center
                        
                        self.showInformationView()
                    }
                    else
                    {
                        printReport(getShelterError ?? "An unknown error occurred.", errorCode: nil, isFatal: true, metaData: [#file, #function, #line])
                    }
                }
            }
            else
            {
                showInformationView()
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func showInformationView()
    {
        UIView.animate(withDuration: 0.2) {
            self.nameLabel.alpha = 0
            self.informationButton.alpha = 0
            self.subtitleLabel.alpha = 0
            
            self.informationView.alpha = 0.93
        }
    }
}
