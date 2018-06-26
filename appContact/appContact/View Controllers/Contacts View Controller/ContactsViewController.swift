//
//  ContactsViewController.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/24/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import AFNetworking

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactTableView: UITableView!
    var contacts = try! Realm().objects(Contact.self).sorted(byKeyPath: "firstName", ascending: true)
    let sectionTitles = ["1", "2" ,"3", "4", "5", "6", "7", "8", "9" , "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setTitleWithColor(title: kTitleContact, color: UIColor.black)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchContacts()
    }
    
    func fetchContacts(){
        
        var sv = UIView()
        if contacts.count == 0 {
            //Add Loading
            sv = UIViewController.displaySpinner(onView: self.view)
        }
        
        let manager = AFHTTPSessionManager()
        let urlString = kUrlBase + kUrlContactsJSON + kUrlJSON
        manager.get(urlString, parameters: nil, progress: nil, success: { (operation, responseObject) in
            
            let response = responseObject as! Array<Any>
            
            DispatchQueue.global().async {
                // Get new realm and table since we are in a new thread
                autoreleasepool {
                    let realm = try! Realm()
                    realm.beginWrite()
                    for i in 0..<response.count {
                        
                        let dict = response[i] as! NSDictionary
                        // Add row via dictionary. Order is ignored.
                        
                        var contact : Contact?
                        var dbContact : Contact?
                        
                        if let id = dict["id"] as? Int {
                            if id != 0 {
                                dbContact = Contact.getById(id: id)
                            }
                        }
                        
                        contact = Contact.inBound(dict: dict, dbContact: dbContact) as Contact
                        realm.add(contact!, update: true)
                    }
                    
                    try! realm.commitWrite()
                    
                }
                
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: sv)
                    self.refresh()
                }
            }
            
            
        }) { (operation, error) in
            
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: sv)
                self.showAlertMessage(vc: self, titleStr: kError, messageStr: kErrorContacts)
            }
        }
    }
    
    func refresh() -> Void {
        self.contacts = try! Realm().objects(Contact.self).sorted(byKeyPath: "firstName", ascending: true)
        self.contactTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addContactClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactDetailVC = storyboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        contactDetailVC.menuMode = .createMode
        
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueDetailContact{
            
        }
    }
    
    func getSectionContacts(section:Int) -> Results<Contact> {
        let query = NSPredicate(format: "firstName BEGINSWITH[c] %@",self.sectionTitles[section])
        return self.contacts.filter(query)
    }
    
}

// MARK: - TableView Delegate
extension ContactsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactDetailVC = storyboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        let contacts : NSArray = Array(self.getSectionContacts(section: indexPath.section)) as NSArray
        let contact : Contact = contacts.object(at: indexPath.row) as! Contact
        contactDetailVC.menuMode = .viewMode
        contactDetailVC.selectedId = contact.id
        
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ContactsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.getSectionContacts(section: section).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = self.sectionTitles[section]
        label.backgroundColor = CommonFunction.hexStringToUIColor(hex: "#E8E8E8")
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.contactTableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        
        let contacts : NSArray = Array(self.getSectionContacts(section: indexPath.section)) as NSArray
        let contact : Contact = contacts.object(at: indexPath.row) as! Contact
        
        cell.nameLabel.text = contact.getFullName()
        cell.favIcon.isHidden = !(contact.isFavorite)
        //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.contactIcon.downloadImageFrom(urlString: contact.profilePic, imageMode: UIViewContentMode.scaleAspectFit)
        
        return cell
    }
    
    
}
