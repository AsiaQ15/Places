//
//  MapManager.swift
//  MyPlaces
//
//  Created by Ася Купинская on 27.10.2022.
//

import UIKit
import MapKit

class MapManager{
    let locationManager = CLLocationManager() //отвечает за настройку и управление службами геолокации
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.0
    //для хранения маршрутов
    private var directionsArray: [MKDirections] = []
    
    func setupPlaceMark(place: Place, mapView: MKMapView){
        //извлекаем адрес заведения
        guard let location = place.loation else {return}
        //класс для преобразования географических  координат и название
        let geocoder = CLGeocoder()
        //по названию возвращается массив меток и ошибку если не нашли
        geocoder.geocodeAddressString(location){ (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            //описание точки на карта
             let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
             mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
   func chekLocationServices(mapView: MKMapView, segueIndentifier: String, clouser: ()->()){
        //проверка включены ли службы геологации
        if CLLocationManager.locationServicesEnabled(){
            //первичная настройка
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIndentifier:segueIndentifier)
            clouser()
        } else {
            //нужно вызвать alert Controller с инструкцией как включить
            //отложенный вызов
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlertController(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
            
        }
        
    }
    
    //проверка на разрение использования геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIndentifier: String){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:  //приложению разрешенно использовать в момент использования
            mapView.showsUserLocation = true
            if segueIndentifier == " " { showUserLocation(mapView: mapView) }
            break
        case .denied: //отказано в использовании или откл. в настройках
            //show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlertController(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
            break
        case .notDetermined: //статус неопределен, пользователь не сделал выбор
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: //приложение не авторизованно для использования служб локации
            break
        case .authorizedAlways: //разрешенно использовать всегда
            break
            
        @unknown default:
            print("new case location")
        }
    }
    
    func showUserLocation(mapView: MKMapView){
        if let location = locationManager.location?.coordinate{
            //опр. регион для позиционирования карты
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true )
        }
    }
    //строим марширут до местоположения пользователя
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()){
        
        //опр. координаты пользователя
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Current location not found")
            return
        }
        //режим постоянного отслеживания местоположения пользователя
        locationManager.stopUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        //выполнить запрос на проклвдку марширута
        
        guard let request = createDirectionsRequest(from: location )else {
            showAlertController(title: "Error", message: "Destination not found")
            return
        }
        
        let directions = MKDirections(request: request)
        //удаление всех текущих маршрутов
        resetMapView(withNew: directions, mapView: mapView)
        //запуск расчета марширута
        directions.calculate{ (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlertController(title: "Error", message: "Directions is not availale")
                return
            }
            
            for rout in response.routes{
                mapView.addOverlay(rout.polyline)
                mapView.setVisibleMapRect(rout.polyline.boundingMapRect, animated: true) //зона видимости карты так чтоб весь марширут влез
                let distance = String(format: "%.1f", rout.distance/1000) //дистанция
                let timeInterval = rout.expectedTravelTime
                print("Расстояние до места \(distance).м")
                print("Время в пути \(timeInterval ).сек")
            }
        }
        
    }
    
    //настройка запроса для построения маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request?{
        //опр. координаты места назначения
        guard let destinationCoordinate = placeCoordinate else { return nil}
        //точка начала марширута
        let startLocation = MKPlacemark(coordinate: coordinate)
        //точка назначения
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        //запрос на построение марширута
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        //тип транспорта
        request.transportType = .automobile
        request.requestsAlternateRoutes = true //позволяет строить несколько маршрутов если есть альтернативные варианты
        
        return request
        
    }
    //меняем отображаемую зону области карты  в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, clouser: (_ currentLocation: CLLocation) -> ()){
        
        guard let location = location else {return}
        let center = getCenterLocation(forMapView: mapView)
        
        //будем обновлять позицию пользователя, если растояние больше 50 метров
        guard center.distance(from: location) > 50 else {return}
        clouser(center)
        
    }
    
    //Сброс всех ранее построенных марширутов перед построением новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView){
        //удаление всех текущих наложений
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let  _ = directionsArray.map{ $0.cancel()}
        directionsArray.removeAll()
    }
    
    //Определдение центра отображаемой области
    func getCenterLocation(forMapView: MKMapView) -> CLLocation{
        
        let latitude = forMapView.centerCoordinate.latitude //широта
        let longitude = forMapView.centerCoordinate.longitude//долгота
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlertController(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    

}
