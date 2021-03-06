//
//  RegisterAccountViewController.swift
//  ArretadasFGC
//
//  Created by Ada 2018 on 31/08/2018.
//  Copyright © 2018 Ada 2018. All rights reserved.
//

import UIKit

class RegisterAccountViewController: UIViewController {

    //outlets
    @IBOutlet var viewHeader: BackgroundUser!
    @IBOutlet var name: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var profession: UITextField!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var viewCard: UIView!
    @IBOutlet var scView: UIScrollView!
    @IBOutlet var cancelButton: UIButton!
    
    
    //constantes
    let labels = ["Nome", "Email", "Ocupação", "Cidade", "Senha"]
    
    //vaiaveis
    var pickedImageName = ""
    var newUser: User!
    var imagePicker = UIImagePickerController()
    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        initialConfg()

    }

    func initialConfg(){
        viewCard.setCornerRadiusDefault()
        
        registerButton.sizeToFit()
        registerButton.primaryButtton()
        registerButton.titleLabel?.sizeToFit()
        newUser = User(context: DataManager.getContext())
        viewHeader.nameLabel.isHidden = true
        viewHeader.profileImageView.isUserInteractionEnabled = true
        viewHeader.profileImageView.addGestureRecognizer(tapGestureRecognizer!)
        viewHeader.addSubview(cancelButton)
        
    }
    
    // Getting the information in textFiels and saving in Core Data
    @IBAction func registerAccount(_ sender: UIButton) {

		if(Register.checkTextFieldIsEmpty(textFields: [self.city, self.name, self.email, self.password, self.profession])){
			let alert = UIAlertController(title: "Complete all the fields", message: nil, preferredStyle: .alert)
			self.present(alert, animated: true, completion: nil)
			let when = DispatchTime.now() + 5
			DispatchQueue.main.asyncAfter(deadline: when){
				alert.dismiss(animated: true, completion: nil)
			}
		}else{
            let alert = UIAlertController(title: "Cadastrado com sucesso!", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            newUser.city = self.city.text
            newUser.password = self.password.text
            newUser.profession = self.profession.text
            newUser.name = self.name.text
            newUser.email = self.email.text
            newUser.photo = StoreMidia.saving(image: viewHeader.profileImageView.image!, withName: pickedImageName)
            DataManager.saveContext()
		}
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification){
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, targetFrame.height, 0.0)
        scView.contentInset = contentInsets
        scView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= targetFrame.height
        if (activeField != nil && !aRect.contains(activeField.frame.origin)) {
            scView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
	
	//Not testable
    
    @objc func keyboardWillHide(notif: Notification){
        let contentInsets = UIEdgeInsetsFromString("")
        scView.contentInset = contentInsets
        scView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        _ = tapGestureRecognizer.view as! UIImageView
        
        let actionSheet: UIAlertController = UIAlertController(title: "Capture an image", message: "Choose an option", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        { _ in
            guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) else {
                let alert: UIAlertController = UIAlertController(title: "Oops...", message: "Camera is not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.imagePicker.sourceType = .camera
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let galeriaAction = UIAlertAction(title: "Library", style: .default)
        { _ in
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galeriaAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }

}


extension RegisterAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.viewHeader.profileImageView.image = pickedImage
            self.pickedImageName = "Arretada\(pickedImage.hashValue)"
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIButton{
    func primaryButtton(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.primary.cgColor
        self.titleEdgeInsets = UIEdgeInsets(top: 15.0, left: 5.0, bottom: 15.0, right: 5.0)
        
        self.setTitleColor(UIColor.primary, for: .normal)
    }
}
