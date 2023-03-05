//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Ася Купинская on 13.09.2022.
//

import RealmSwift
//создаем экземпляр realm
let realm = try! Realm()


class StorageManager{
    
    static func saveObject(_ place: Place){
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place){
        try! realm.write {
            realm.delete(place)
        }
    }
}
