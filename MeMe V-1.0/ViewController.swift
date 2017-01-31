//
//  ViewController.swift
//  MeMe V-1.0
//
//  Created by Vasanth Kodeboyina on 6/1/16.
//  Copyright © 2016 Anish Kodeboyina. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    var selectedTextField: UITextField!
    var memedImage: UIImage!
    var pickerController: UIImagePickerController!
    let cannotAccessCameraAlertMessage = "Application cannot access the camera"

    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        shareButton.isEnabled = false
        cameraAvailabilityCheck()
        let textFieldsArray = [topTextField, bottomTextField]
        textFieldsConfiguration(textFieldsArray)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(true)
        unsubsribeToKeyboardNotification()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true) // KeyBoard will disappear when user Tap on view
    }
    
    
    // MARK: - Image Picking and Delegation

    // Album Button is Pressed: Pick Image from Photo Library
    @IBAction func pickAnImage(_ sender: AnyObject)
    {
        pickerController = imagePickerWith(.photoLibrary)
        pickerController.delegate = self
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // Image Picking Delegation : Selected image assigned to ImageViewer
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        imageViewer.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        pickerController.dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    // Image Picking Delegation : Selected image assigned to ImageViewer
    func imagePickerWith(_ type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = type
        return pickerController
    }
    
    
    // MARK: - Camera Button Pressed Actions
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject)
    {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil
            {
                pickerController = imagePickerWith(.camera)
                pickerController.allowsEditing = false
                pickerController.cameraCaptureMode = .photo
                present(pickerController, animated: true, completion: {})
            }
            else
            {
                createAlertWithMessage("No Rear Camera")
            }
    }
    
    // Check for camera avaialbility in device
    func cameraAvailabilityCheck()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            cameraButton.isEnabled = true
        }
        else
        {
            cameraButton.isEnabled = false
        }
        
    }
    
    
    // Alert Message with Ok Action
    func createAlertWithMessage(_ title: String)
    {
        let UIAlert = UIAlertController(title: title, message: cannotAccessCameraAlertMessage, preferredStyle: UIAlertControllerStyle.alert)
        UIAlert.addAction(UIAlertAction(title: "ok",style: .default, handler: {(ACTION:UIAlertAction!) in }))
        present(UIAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Share Button Pressed Actions

    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        let imageToShare = generateMemedImage()
        let activityItems = [imageToShare]
        let ac = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(ac, animated: true, completion: {self.save()})
    }
    
    func save() {
        //Create the meme
       let meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewer.image, memedImage: memedImage)
        print(meme)
        cancelButtonPressed(true as AnyObject)
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide Toolbar
        var size = view.frame.size
        size.height -= topToolbar.frame.size.height + 20
        size.height -= bottomToolbar.frame.size.height 
        
        //render view to an image:
        var frame = self.view.frame
        frame.origin.y -= (topToolbar.frame.size.height + 20)
        UIGraphicsBeginImageContext(size)
        self.view.drawHierarchy(in: frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    // MARK: - KeyBoard Resigning and Notification
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        selectedTextField = textField
    }
    
    
    // Calculation of keyBoard Height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Move frame upward
    func keyboardWillShow(_ notification: Notification)
    {
        if selectedTextField == bottomTextField && self.view.frame.origin.y == 0.0
        {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Move frame back to its original position
    func keyboardWillHide(_ notification: Notification)
    {
        if -self.view.frame.origin.y > 0
        {
            self.view.frame.origin.y = 0
        }
    }
   
    //Suscribe the view controller to the UIKeyboardWillShowNotification:
    func subscribeToKeyboardNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Unsubscribe the view controller to the UIKeyboardWillShowNotification:
    func unsubsribeToKeyboardNotification()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - TextFields Configuration
    
    func textFieldsConfiguration(_ textFields: [UITextField?])
    {
        let memeTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 40)!,
            NSStrokeWidthAttributeName : -4.0
        ] as [String : Any]
        
        for textField in textFields
        {
            textField?.defaultTextAttributes = memeTextAttributes
            textField?.textAlignment = .center
        }
    }
    
    // MARK: - Cancel Button Pressed Actions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject)
    {
        topTextField.text = nil                     // Clear Top TextField
        bottomTextField.text = nil                  // Clear Bottom TextField
        imageViewer.image = nil                     // Clear ImageViewer
        shareButton.isEnabled = false                 // Disabled share button
        if(selectedTextField != nil)
        {
            textFieldShouldReturn(selectedTextField)    // Keyboard should resign
        }
    }
    
}

