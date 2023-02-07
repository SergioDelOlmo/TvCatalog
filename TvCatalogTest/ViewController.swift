//
//  ViewController.swift
//  TvCatalogTest
//
//  Created by Sergio Del Olmo Aguilar on 29/11/22.
//

import UIKit
import SQLite3

//MARK: - Logic Variables
var tvShows:[TvShow] = []
var favoriteTvShows:[TvShow] = []
var urlTvmaze:String = "https://api.tvmaze.com/schedule?country=US&date=2022-11-29"
var urlImdb:String = "https://www.imdb.com/title/"
let favoritesKey: String = "favoritesData"

class ViewController: UIViewController {
    //MARK: - UIElements
    @IBOutlet weak var TableViewMain: UITableView!
    
    //MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrieveFavorites()
        self.initialConfiguration()
        self.fetchTvShows()
        
        let documentDirectory = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func matchSavedFavorites(){
        if !favoriteTvShows.isEmpty {
            for show in favoriteTvShows {
                guard let index = tvShows.firstIndex(where: {$0.id == show.id}) else {return}
                tvShows[index].isFavourite = true
            }
        }
    }
    
    func initialConfiguration(){
        TableViewMain.register(UINib(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "TableViewCellId")
        TableViewMain.dataSource = self
        TableViewMain.delegate = self
    }
    
    //MARK: - Get Data From Url
    func fetchTvShows(){
        //Formamos la url
        guard let url = URL(string: urlTvmaze) else {
            showError(message: "An error ocurred while querying the service. \nWant to try again?")
            return
        }
        //Formamos el request
        let urlRequest = URLRequest(url: url)
        //Referencia al singleton de URLSession, con configuración por default
        let session = URLSession.shared
        //Creamos una tarea para manejar el response
        let task = session.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showError(message: error.localizedDescription)
                }
                return
            }
            guard let data = data,
                  let response = try? JSONDecoder().decode([TvShow].self, from: data) else {
                DispatchQueue.main.async {
                    self.showError(message: "Response error ocurred")
                }
                return
            }
            DispatchQueue.main.async {
                tvShows = response
                self.TableViewMain.reloadData()
                self.matchSavedFavorites()
            }
        }
        //Ejecutamos la task
        task.resume()
        
    }
    
    //MARK: - ShowError
    func showError(message:String){
        let alertController = UIAlertController(title: "Oops, something went wrong!", message: message, preferredStyle: .alert)
        present(alertController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            alertController.dismiss(animated: true)
        })
        
    }
    
    //MARK: - Navigation Management
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? DetailViewController,
           let model = sender as? TableViewCellProtocol {
            destination.tvShow = model as? TvShow
            segue.destination.navigationItem.title = model.getShowName()
        }
    }
    
    //MARK: - Persisting data
    func persistFavorites(){
        if let encodedData = try? JSONEncoder().encode(favoriteTvShows) {
            //Se pudo formar el json desde los datos
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        } else {
            showError(message: "Error trying to save data")
        }
    }
    
    //MARK: - Retrieving data
    func retrieveFavorites(){
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let savedFavorites = try? JSONDecoder().decode([TvShow].self, from: data) else {
            self.showError(message: "There was an error trying to retrieve Favorites list")
            return
        }
        favoriteTvShows = savedFavorites
//        matchSavedFavorites()
    }

}

//MARK: - DataSource
extension ViewController : UITableViewDataSource {
    
    //Número de filas (en la sección)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvShows.count
    }
    
    //Definir la celda que se pintará en cada fila
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = TableViewMain.dequeueReusableCell(withIdentifier: "TableViewCellId", for: indexPath) as? TableViewCell else {return TableViewCell()}
        let model = tvShows[indexPath.row]
        cell.drawData(model: model)
        return cell
    }
    
    //MARK: - Swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Si el show ya es favorito => Se puede borrar
        if favoriteTvShows.contains(where: {$0.id == tvShows[indexPath.row].id}) {
            
            //Se crea acción para borrar
            let action = UIContextualAction(style: .normal, title: "Delete") { action, view, completion in
                completion(true)
                
                //MARK: - EraseAlert
                let alertController = UIAlertController(title: "Attention!", message: "You're about to erase a TV Show from Favorites Catalog", preferredStyle: .alert)
                //Accept
                alertController.addAction(UIAlertAction(title: "Accept", style: .destructive, handler: { action in
                    //Si es Accept => Se hace el borrado
                    favoriteTvShows.remove(at: favoriteTvShows.firstIndex(where: {$0.id == tvShows[indexPath.row].id})!)
                    tvShows[indexPath.row].isFavourite = false
                    self.persistFavorites()
                }))
                //Cancel
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    //Si es Cancel => No pasa nada
                }))
                self.present(alertController, animated: true)
            }
            action.backgroundColor = .red
            let config = UISwipeActionsConfiguration(actions: [action])
            return config
            
            //Si el show no es favorito => Se puede agregar
        } else {
            
            //Se crea acción para agregar
            let action = UIContextualAction(style: .normal, title: "Favorite") { action, view, completion in
                completion(true)
                
                //Se agrega a favoritos y se marca el show como favorito
                favoriteTvShows.append(tvShows[indexPath.row])
                tvShows[indexPath.row].isFavourite = true
                self.persistFavorites()
                //MARK: - AddAlert
                let alertController = UIAlertController(title: "Attention!", message: "TV Show added to Favorites", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Accept", style: .default))
                self.present(alertController, animated: true)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    alertController.dismiss(animated: true)
//                })
            }
            action.backgroundColor = .green
            let config = UISwipeActionsConfiguration(actions: [action])
            return config
        }
    }
    
}

//MARK: - Delegate
extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tvShow = tvShows[indexPath.row]
        performSegue(withIdentifier: "ShowDetail", sender: tvShow)
    }
    
    
}
