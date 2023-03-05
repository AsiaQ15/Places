//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Ася Купинская on 10.09.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView!{
        didSet{
            
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2 //скруглили отображение картинки
            imageOfPlace.clipsToBounds = true  //орезали картинку под отображение
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!{
        didSet{
            //откл возможность менять колл-во звезд на главном экране
            cosmosView.settings.updateOnTouch  = false
        }
    }
}
 
