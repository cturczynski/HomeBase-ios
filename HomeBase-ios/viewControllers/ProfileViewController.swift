//
//  ProfileViewController.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation
import UIKit
import RSKImageCropper
import Toast

class ProfileViewController: NavBarViewController, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, RSKImageCropViewControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var chosenImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = currentUser {
            nameLabel.text = user.name
            nameLabel.adjustsFontSizeToFitWidth = true
            emailLabel.text = user.email
            emailLabel.adjustsFontSizeToFitWidth = true
            phoneLabel.text = formatPhoneNumber(phone: user.phone)
            phoneLabel.adjustsFontSizeToFitWidth = true
            startDateLabel.text = createDateFormatter(withFormat: "MM/dd/yyyy").string(from: user.startDate)
            startDateLabel.adjustsFontSizeToFitWidth = true
            
            profileImageView.contentMode = .scaleAspectFit
            if let picString = currentUser?.profileImageString, let picData = Data(base64Encoded: picString, options: .ignoreUnknownCharacters), let image = UIImage(data: picData){
                chosenImage = image
                profileImageView.image = chosenImage
            } else {
                profileImageView.image = UIImage(named: "profile-icon")
            }
        } else {
            currentUserShifts = nil
            allEmployees = nil
            makeNewRootController(vcId: "LoginViewController", fromController: self)
        }
        
        //add tap gesture to profile pic to edit
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.uploadPhoto))
        tap.delegate = self
        tap.cancelsTouchesInView = true
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
    }
    
    @objc func uploadPhoto() {
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default) { UIAlertAction in
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                displayAlert("Warning", message: "You do not have camera functionality.", sender: self)
            }
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default) { UIAlertAction in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in
            // Cancel the UIAlert
        }
        
        // Add the actions
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let chosenImage = (info[.originalImage] as! UIImage).resized(toWidth: 300)!
        
        let imageCropperVC = RSKImageCropViewController(image: chosenImage, cropMode: .circle)
        imageCropperVC.delegate = self
        imagePicker.pushViewController(imageCropperVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        imagePicker.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        chosenImage = croppedImage
        let jpegImage = croppedImage.jpegData(compressionQuality: 0.33)! as NSData
        let imageString = jpegImage.base64EncodedString(options: .lineLength64Characters)
        currentUser?.profileImageString = imageString
        dismiss(animated: true) {
            self.saveNewUserData()
        }
    }
    
    func saveNewUserData() {
        startLoadingView(controller: self)
        EmployeeRequest.init(action: "update").saveToDb(obj: currentUser!) { [weak self] result in
            DispatchQueue.main.async {
                switch(result) {
                case .failure(let error):
                    print(error)
                    displayAlert("Error", message: "Could not save profile image at this time.", sender: self!)
                case .success(let updateResult):
                    print(updateResult)
                    self?.profileImageView.image = self?.chosenImage
                    self?.view.makeToast("Profile image saved.", duration: 2.0, position: CSToastPositionCenter)
                }
                endLoadingView()
            }
        }
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        currentUser = nil
        currentUserShifts = nil
        makeNewRootController(vcId: "LoginViewController", fromController: self)
    }
}
