//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Ася Купинская on 15.10.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate{
    func getAdress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControlllerDelegate: MapViewControllerDelegate?
    var place = Place()
     
    let annotationIndentifier = "annotationIndentifier"
    var incomeSegueIndentifier = ""

    var previousLocation: CLLocation? {
        didSet{
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation){
                (currentlocation) in
                self.previousLocation = currentlocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()

    }
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func closeVC() {
        //закрывам VC и выгружаем его из памяти 
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView){ (location) in
            self.previousLocation = location
        }
    }
    @IBAction func doneButtonPressed() {
        //передаем адрес 
        mapViewControlllerDelegate?.getAdress(addressLabel.text)
        dismiss(animated: true) //закрываем viewController
    }
    private func setupMapView(){
        
        goButton.isHidden = true
        
        mapManager.chekLocationServices(mapView: mapView, segueIndentifier: incomeSegueIndentifier){
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIndentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}
//для более тонкой работы с картами
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //маркер на карте Не является текущим положением пользователя
        guard !(annotation is MKUserLocation) else {return nil}
        //не создавать новые, а переиспользовать ранее использоваемые
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIndentifier) as? MKPinAnnotationView
        //если ранее не было представления
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIndentifier)
            annotationView?.canShowCallout = true
        }
        //добавляем изображение
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds  = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView  = imageView
        }
        
        return annotationView
    }
    //следит за изменением отображаемой области карты
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(forMapView: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIndentifier == "ShowPlace" && previousLocation != nil{
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        //для освобождения георесурсов
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center){ (placemarks, error) in
            if let error = error{
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!) \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
        
    }
    
    //для отображений марширутов на крте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //рендер наложения сделанного ранее
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
        
    }
}
//для отслеживания  в реальном времени
extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIndentifier: incomeSegueIndentifier)
    }
}
