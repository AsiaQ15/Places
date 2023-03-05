//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Ася Купинская on 07.09.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    private let searchController = UISearchController(searchResultsController: nil) //добавля nil searchResultsController говорим что хотим видеть результаты поиска в том же viewcontroller, где отображается основной контент
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorted = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    } //пустая строка поиска или нет
    private var isFiltering: Bool{
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //отобразить данные  на экране
        places = realm.objects(Place.self)
        
        //setup the searchController
        searchController.searchResultsUpdater = self //получателем информации об изменении текстов будет сам класс
        searchController.obscuresBackgroundDuringPresentation =  false // позволяем взаимодействовать с viewControllerom как с основным
        searchController.searchBar.placeholder = "Search"//название строки поиска
        navigationItem.searchController = searchController
        definesPresentationContext = true //отпустить строку поиска при переходе на другой  экран
        
        
    }

    // MARK: - Table view data source
    //отменим выделение ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   //количество строк
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }

    //конфигурация ячеек
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //создаем объем ячейка
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
      
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.loation
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
        
//        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //скруглили отображение картинки
//        cell.imageOfPlace.clipsToBounds = true  //орезали картинку под отображение

        return cell
    }
     
    // MARK: Table View delegate
    
    //вызов пунктов меню свайпом по ячейке вправо
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    
    //возвращает высоту строки (установили в Main)
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //переходим на редактирование
        if segue.identifier == "showDetail" {
            //передаем объект с типом  из выбраной Place ячейки на NewPlaceViewController
            guard let indexPath = tableView.indexPathForSelectedRow  else {return}
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            let newPlaceVC = segue.destination  as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){

        guard let newPlaceVC = segue.source as? NewPlaceViewController else{return}
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorted.toggle()
        
        if ascendingSorted{
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
     
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorted )
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorted)
        }
        tableView.reloadData()
    }
}

extension MainViewController:  UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String){
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR loation CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
 
