//
//  ViewController.swift
//  UploadImagesFireStorage
//
//  Created by Volodymyr Ostapyshyn on 28.11.2020.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var label: UILabel!
    
    
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.numberOfLines = 0
        label.textAlignment = .center
        image.contentMode = .scaleAspectFit
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url = URL(string: urlString) else {
            print("error user def")
            return
        }
        
        label.text = urlString
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.image.image = image
            }
        }
        task.resume()

    }
    
    @IBAction func didTapUploadButton(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        
        storage.child("prizes/file.png").putData(imageData, metadata: nil) {  (_, error) in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            self.storage.child("prizes/file.png").downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("test")
                    return
                }
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.label.text = urlString
                    self.image.image = image
                }
                
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            }
             
        
        }
    }
    

}

