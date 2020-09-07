//
//  ChatCell.swift
//  Boop (Code Name Gamma)
//
//  Created by Grant Brooks Goodman on 24/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

import MessageKit

class ChatCell: UITableViewCell
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UILabels
    @IBOutlet weak var nameLabel:    UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var unreadView: UIView!
    
    @IBOutlet weak var avatarView: AvatarView!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
