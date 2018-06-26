//
//  Person.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/24/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var email = ""
    @objc dynamic var phoneNumber = ""
    @objc dynamic var profilePic = kUrlBase + "/images/missing.png"
    @objc dynamic var isFavorite = false
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Person.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func updateCurrentId() -> Void {
        let realm = try! Realm()
        if !realm.isInWriteTransaction {
            realm.beginWrite()
        }
        self.id = self.incrementID()
    }
    
    class func inBound(dict : NSDictionary, dbPerson : Person?) -> Person {
        
        var person = Person()
        
        if let input = dbPerson{
            person = input
        }
        
        if person.id == 0 {
            person.id = dict["id"] as! Int
        }
        
        person.firstName = dict["first_name"] as! String
        person.lastName = dict["last_name"] as! String
        person.email = dict["email"] as! String
        person.phoneNumber = dict["phone_number"] as! String
        
        if (CommonFunction.verifyUrl(urlString: (dict["profile_pic"] as! String))){
            person.profilePic = (dict["profile_pic"] as! String)
        }
        else{
            person.profilePic = kUrlBase + (dict["profile_pic"] as! String)
        }
        
        person.isFavorite = dict["favorite"] as! Bool
        person.createdAt = CommonFunction.dateFromString(input: dict["created_at"] as! String) 
        person.updatedAt = CommonFunction.dateFromString(input: dict["updated_at"] as! String) 
        
        return person
    }
    
    class func postOutBound(person : Person) -> Dictionary<String, Any> {
        return ["id": person.id,
                "first_name": person.firstName,
                "last_name": person.lastName,
                "email": person.email,
                "phone_number": person.phoneNumber,
                "profile_pic": person.profilePic,
                "favorite": person.isFavorite,
                "created_at": CommonFunction.stringFromDate(input: person.createdAt),
                "updated_at": CommonFunction.stringFromDate(input: person.updatedAt),
        ]
    }
    
    class func putOutBound(person : Person) -> Dictionary<String, Any> {
        return ["first_name": person.firstName,
                "last_name": "test",
                "email": person.email,
                "phone_number": person.phoneNumber,
                "profile_pic": person.profilePic,
                "favorite": person.isFavorite,
                "created_at": CommonFunction.stringFromDate(input: person.createdAt),
                "updated_at": CommonFunction.stringFromDate(input: person.updatedAt),
        ]
    }
    
    class func getById(id : Int) -> Person? {
        let person :Person? = try! Realm().object(ofType: Person.self, forPrimaryKey: id)
        
        if person != nil {
            return person!
        }
        
        return nil
    }
    
    func getFullName() -> String {
        return self.firstName + " " + self.lastName;
    }
    
    func getUIOutput(nameLabel : String) -> String {
        switch nameLabel {
        case kPersonFirstName:
            return self.firstName
        case kPersonLastName:
            return self.lastName
        case kPersonMobile:
            return self.phoneNumber
        case kPersonEmail:
            return self.email
        default: break
        }
        
        return ""
    }
    
    func updateValue(key:String, value :String, vc : UIViewController) -> Void {
        let realm = try! Realm()
        if !realm.isInWriteTransaction {
            realm.beginWrite()
        }
        
        switch key {
        case kPersonFirstName:
            self.firstName = value
            break
        case kPersonLastName:
            self.lastName = value
            break
        case kPersonMobile:
            self.phoneNumber = value
            break
        case kPersonEmail:
            self.email = value
            break
        default: break
        }
    }
    
    func validateProperties (vc : UIViewController) -> Bool {
        if !CommonFunction.isValidName(self.firstName){
            vc.showAlertMessage(vc: vc, titleStr: kError, messageStr: kErrorFirstNameValidation)
            return false
        }else if !CommonFunction.isValidName(self.lastName){
            vc.showAlertMessage(vc: vc, titleStr: kError, messageStr: kErrorLastNameValidation)
            return false
        }else if !CommonFunction.isValidName(self.phoneNumber){
            vc.showAlertMessage(vc: vc, titleStr: kError, messageStr: kErrorPhoneValidation)
            return false
        }else if !self.email.isValid(regex: .email){
            vc.showAlertMessage(vc: vc, titleStr: kError, messageStr: kErrorEmailValidation)
            return false
        }
        
        return true
    }
}
