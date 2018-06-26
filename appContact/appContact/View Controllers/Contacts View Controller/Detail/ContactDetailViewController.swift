//
//  ContactDetailViewController.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/25/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import AFNetworking
import MessageUI

enum MenuMode: Int {
    case unknown = 0
    case viewMode
    case editMode
    case createMode
}

class ContactDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var hasChanges : Bool = false
    var selectedId : Int = 0
    var selectedPerson = Person()
    var cellLabelArray = NSMutableArray()
    
    var menuMode:MenuMode = MenuMode.unknown
    
    @IBOutlet weak var middleStackView: UIStackView!
    
    @IBOutlet weak var personIcon: CustomImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Contacts", style: .plain, target: self, action: #selector(cancelOperation))
        
        switch menuMode {
        case .createMode:
            self.setupCreateMode()
            break
        case .editMode:
            self.setupCreateMode()
            break
        default:
            self.getPerson()
            self.setupViewMode()
            break;
        }
        
    }
    
    @objc func cancelOperation() -> Void {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            realm.cancelWrite()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setClickableImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickImageClicked(gesture:)))
        
        // add it to the image view;
        self.personIcon.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        self.personIcon.isUserInteractionEnabled = true
    }
    
    // MARK: - Setup Create Mode
    @objc func setupCreateMode()
    {
        menuMode = MenuMode.createMode
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(createContact))
        self.middleStackView.isHidden = true
        self.fullNameLabel.text = ""
        self.cellLabelArray = [kPersonFirstName,kPersonLastName,kPersonMobile,kPersonEmail]
        
        if self.personIcon.image == nil {
            self.personIcon.downloadImageFrom(urlString: self.selectedPerson.profilePic, imageMode: UIViewContentMode.scaleAspectFit)
        }
        
        self.setClickableImage()
        
        self.detailTableView.reloadData()
    }
    
    // MARK: - Setup View Mode
    @objc func setupViewMode()
    {
        self.view.endEditing(true)
        
        menuMode = MenuMode.viewMode
        self.middleStackView.isHidden = false
        
        if self.selectedPerson.isFavorite {
            self.favoriteButton.setImage(UIImage(named: "ic_favorite"), for: UIControlState.normal)
        }
        else{
            self.favoriteButton.setImage(UIImage(named: "ic_favorite_disabled"), for: UIControlState.normal)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(setupEditMode))
        
        self.cellLabelArray = [kPersonMobile,kPersonEmail]
        if self.selectedId != 0 || self.selectedPerson.id != 0 {
            if let person = Person.getById(id: selectedId){
                self.selectedPerson = person
                
                if self.personIcon.image == nil {
                    self.personIcon.downloadImageFrom(urlString: self.selectedPerson.profilePic, imageMode: UIViewContentMode.scaleAspectFit)
                }
            }
            
            self.fullNameLabel.text = self.selectedPerson.getFullName()
        }
        self.personIcon.isUserInteractionEnabled = false
        self.detailTableView.reloadData()
    }
    
    // MARK: - Setup Edit Mode
    @objc func setupEditMode()
    {
        menuMode = MenuMode.editMode
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(updateContact))
        self.middleStackView.isHidden = true
        self.cellLabelArray = [kPersonFirstName,kPersonLastName,kPersonMobile,kPersonEmail]
        self.setClickableImage()
        self.detailTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func messageClicked(_ sender: Any) {
        self.sendMessage(phoneNumber: self.selectedPerson.phoneNumber)
    }
    
    @IBAction func callClicked(_ sender: Any) {
        CommonFunction.makeCall(phoneNumber: self.selectedPerson.phoneNumber)
    }
    
    @IBAction func emailClicked(_ sender: Any) {
        self.sendEmail(email: self.selectedPerson.email)
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        self.selectedPerson.isFavorite = !self.selectedPerson.isFavorite
    }
    
    // MARK: - Web Services
    //Get Person Detail
    func getPerson() {
        var sv = UIView()
        
        if selectedId != 0 {
            
            if let person = Person.getById(id: selectedId) { // If casting, use, eg, if let var = abc as? NSString
                // variableName will be abc, unwrapped
                self.selectedPerson = person
                self.setupViewMode()
            } else {
                sv = UIViewController.displaySpinner(onView: (UIApplication.shared.keyWindow!.rootViewController?.view)!)
                let manager = AFHTTPSessionManager()
                let urlString = kUrlBase + kUrlContacts + "\(selectedId)" + kUrlJSON
                manager.get(urlString, parameters: nil, progress: nil, success: { (operation, responseObject) in
                    
                    let response = responseObject as! NSDictionary
                    
                    DispatchQueue.global().async {
                        // Get new realm and table since we are in a new thread
                        autoreleasepool {
                            let realm = try! Realm()
                            if !realm.isInWriteTransaction {
                                realm.beginWrite()
                            }
                            
                            var person : Person?
                            var dbPerson : Person?
                            
                            if let id = response["id"] as? Int {
                                if id != 0 {
                                    dbPerson = Person.getById(id: id)
                                }
                            }
                            
                            if response.count > 0 {
                                person = Person.inBound(dict: response, dbPerson: dbPerson)
                                realm.add(person!, update: true)
                            }
                            
                            try! realm.commitWrite()
                        
                        }
                        
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            self.setupViewMode()
                        }
                    }
                    
                }) { (operation, error) in
                    
                    DispatchQueue.main.async {
                        self.showAlertMessage(vc: self, titleStr: kError, messageStr: kErrorContactDetail)
                        UIViewController.removeSpinner(spinner: sv)
                    }
                }
            }
        }
    }
    
    //Create Contact
    @objc func createContact() {
        self.view.endEditing(true)
        self.selectedPerson.updateCurrentId()
        if self.allValidations() {
            self.syncContact(method: "POST", urlString: kUrlSecuredBase + kUrlContacts, param: Person.postOutBound(person: self.selectedPerson))
        }
    }
    
    //Update Contact
    @objc func updateContact() {
        self.view.endEditing(true)
        if self.allValidations() {
            self.syncContact(method: "PUT", urlString: kUrlBase + kUrlContacts + "\(self.selectedId)", param: Person.putOutBound(person: self.selectedPerson))
        }
    }
    
    //Sync Contact
    func syncContact(method:String, urlString:String, param:Dictionary<String, Any>){
        var sv = UIView()
        
        sv = UIViewController.displaySpinner(onView: (UIApplication.shared.keyWindow!.rootViewController?.view)!)
        let updatedAt = Date()
        
        let realm = try! Realm()
        if !realm.isInWriteTransaction {
            realm.beginWrite()
        }
        self.selectedPerson.updatedAt = updatedAt
        
        var request = CommonFunction.getURLRequest(urlString: urlString)
        request.httpMethod = method
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: (param as [String : Any]), options: .prettyPrinted)
            
            request.httpBody = jsonData
        } catch let error as NSError {
            print(error)
        }
        
        self.execTask(request: request) { (success, response) in
            
            DispatchQueue.main.async {
                if success {
                    if realm.isInWriteTransaction{
                        try! realm.commitWrite()
                    }
                    
                    self.setupViewMode()
                }else{
                    self.showAlertMessage(vc: self, titleStr: kError, messageStr: kErrorUpdateCreateContact)
                }
                
                UIViewController.removeSpinner(spinner: sv)
            }
        }
    }
    
    //Add this to handle different webservice req
    private func execTask(request: URLRequest, taskCallback: @escaping (Bool,
        AnyObject?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self as? URLSessionDelegate, delegateQueue: nil )
        
        session.dataTask(with: request) {(data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
            }.resume()
    }
    
    //Send Text Message
    func sendMessage (phoneNumber: String!) -> Void {
        if CommonFunction.isValidPhone(phoneNumber) {
            let controller = MFMessageComposeViewController()
            controller.body = "This is App Contact"
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            if MFMessageComposeViewController.canSendText() {
                self.present(controller, animated: true, completion: nil)
            }
        }
        else{
            print("Failed Send Message")
        }
    }
    
    //Send Email
    func sendEmail (email: String?) -> Void {
        if (email?.isValid(regex: .email))!{
            let composeVC = MFMailComposeViewController()
            
            composeVC.setToRecipients([email!])
            composeVC.setSubject("")
            composeVC.setMessageBody("", isHTML: false)
            composeVC.mailComposeDelegate = self
            if MFMailComposeViewController.canSendMail() {
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func pickImageClicked(gesture: UIGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension ContactDetailViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellLabelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "PersonCell") as! PersonCell
        
        let nameLabel = cellLabelArray[indexPath.row] as? String
        cell.nameLabel.text = nameLabel
        cell.inputTextField.text = self.selectedPerson.getUIOutput(nameLabel: nameLabel!)
    
        //CLOSURE
        cell.inputTextField.endlabelEdit = { (sender) in
            self.hasChanges = true
            self.selectedPerson.updateValue(key: nameLabel!, value: cell.inputTextField.text!, vc: self)
        }
        
        cell.inputTextField.isEnabled = (self.menuMode != .viewMode)
        
        return cell
    }
    
    func allValidations() -> Bool {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            
            if !self.selectedPerson.validateProperties(vc: self){
                return false
            }
            
            return true
        }
        
        self.setupViewMode()
        return false
    }
    
}

extension ContactDetailViewController : MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //After Choosing Image from Gallery or Camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.personIcon.image = editedImage
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
    }
}
