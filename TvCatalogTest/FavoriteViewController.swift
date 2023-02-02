//
//  FavoriteViewController.swift
//  TvCatalogTest
//
//  Created by Sergio Del Olmo Aguilar on 30/11/22.
//

import UIKit

class FavoriteViewController: UIViewController {
    let ViewControllerInstance = ViewController()
    
    //MARK: - UIElements
    @IBOutlet weak var FavoriteTableView: UITableView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FavoriteTableView.register(UINib(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "TableViewCellId")
        FavoriteTableView.dataSource = self
        FavoriteTableView.delegate = self
        FavoriteTableView.reloadData()
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
    
}

//MARK: - Extensions
extension FavoriteViewController:UITableViewDataSource {
    
    //Número de filas en la sección (en este caso sólo hay una sección)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteTvShows.count
    }
    
    //Se define la celda que se pintará en cada fila
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = FavoriteTableView.dequeueReusableCell(withIdentifier: "TableViewCellId", for: indexPath) as? TableViewCell else {return TableViewCell()}
        let model = favoriteTvShows[indexPath.row]
        cell.drawData(model: model)
        return cell
    }
    
    //Tipo de edisión que se hará a la celda
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Función que se encarga de borrar las celdas
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            //Se presenta alerta de confirmación
            let alertController = UIAlertController(title: "Attention!", message: "You're about to erase a TV Show from Favorites Catalog", preferredStyle: .alert)
            //Borrar
            alertController.addAction(UIAlertAction(title: "Accept", style: .destructive, handler: { action in
                //Borrar celda y actualizar arreglo
                favoriteTvShows.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.ViewControllerInstance.persistFavorites()
            }))
            //Nada
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            }))
            present(alertController, animated: true)
            tableView.endUpdates()
        }
    }
    
}

extension FavoriteViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tvShow = favoriteTvShows[indexPath.row]
        performSegue(withIdentifier: "showDetailFromFavorite", sender: tvShow)
    }
}
