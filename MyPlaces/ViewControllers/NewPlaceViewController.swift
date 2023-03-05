//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Ася Купинская on 10.09.2022.
//

import UIKit


class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false

    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    @IBOutlet weak var ratingControl: RatingControl!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //чтобы лишниие линии под таблицей не отображались
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //кнопка save не доступна пока не ввели в поле name
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
  
    }
     
    // MARK: Tabel View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
            let cameraIcon = #imageLiteral(resourceName: "camera.jpg")
            let photoIcon = #imageLiteral(resourceName: "Photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            //ДЕЙСТВИЯ ДЛЯ AlertController: camera, photo, cencel
            //пользовательское действие с вызовом камер
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                //метод вызова камеры
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            //пользовательское действие с выбором фото
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                //метод выбора фото
                self.chooseImagePicker(source: .photoLibrary)
                
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            //пользовательское действие с отменой вызова меню
            let cencel = UIAlertAction(title: "Cencel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cencel)
            //вызов actionSheet
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else {return}
        
        mapVC.incomeSegueIndentifier = identifier
        mapVC.mapViewControlllerDelegate = self
        
        if identifier == "showPlace"{
            mapVC.place.name = placeName.text!
            mapVC.place.loation = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }


    }
    
    func savePlace(){
        
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "Photo")

        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text!,
                             type: placeType.text!, imageData: imageData, rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            try! realm.write{
                currentPlace?  .name = newPlace.name
                currentPlace?.loation = newPlace.loation
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        

    }
    
    //при открытие формы на редактирования старой записи
    private func setupEditScreen(){
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            placeImage.image = image
            //масштабирование изображение под view
            placeImage.contentMode = .scaleAspectFit
            placeName.text = currentPlace?.name
            placeType.text = currentPlace?.type
            placeLocation.text = currentPlace?.loation
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar(){
        //убираем название контроллера с кнопки возврата
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }

    @IBAction func cencelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
//MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate{
    //скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false{
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
}

//MARK: work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate{
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate{
    func getAdress(_ address: String?) {
        placeLocation.text = address
    }
    
     
}
