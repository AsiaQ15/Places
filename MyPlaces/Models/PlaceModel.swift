//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Ася Купинская on 10.09.2022.
//

import RealmSwift

class Place: Object{
    
    @objc dynamic var name: String = ""
    @objc dynamic var loation: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var placeImage: String?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    
    
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating:Double){
        self.init()
        self.name = name
        self.loation = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
   // let placesName = ["Театр музыкальной комедии","Мюзик-холл","ТЮЗ","Театр Ленсовета"]
    
//    var places = [Place(name: "Театр музыкальной комедии", loation: "СПб, Итальянская улица, 13", type: "Театр", image: nil, placeImage: "Театр музыкальной комедии"), Place(name: "Мюзик-холл", loation: "СПб, Александровский парк, 4", type: "Театр", image: nil,placeImage: "Мюзик-холл"), Place(name: "ТЮЗ", loation: "СПб, Пионерская площадь, 1", type: "Театр", image: nil, placeImage: "ТЮЗ"), Place(name: "Театр Ленсовета", loation: "СПб, Владимирский проспект, 12", type: "Театр",image: nil, placeImage: "Театр Ленсовета")]
    
//    func savePlaces(){
//        for place in placesName {
//            let image = UIImage(named: place)
//            guard let imageData = image?.pngData() else {return}
//            let newPlace = Place()
//
//            newPlace.name = place
//            newPlace.loation = "СПб"
//            newPlace.type = "Театр"
//            newPlace.imageData = imageData
//
//            StorageManager.saveObject(newPlace)
//        }
//    }
    
}
