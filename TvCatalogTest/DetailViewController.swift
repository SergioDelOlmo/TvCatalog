//
//  DetailViewController.swift
//  TvCatalogTest
//
//  Created by Sergio Del Olmo Aguilar on 30/11/22.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    //MARK: - Logic Variables
    var tvShow:TvShow!
    var endpoint:String = ""
    let ViewControllerInstance = ViewController()
    
    //MARK: - UIElements
    @IBOutlet weak var FavoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var DetailImageView: UIImageView!
    @IBOutlet weak var SummaryTextView: UITextView!
    @IBOutlet weak var TypeLabel: UILabel!
    @IBOutlet weak var ScheduleTextView: UITextView!
    @IBOutlet weak var ImdbButton: UIButton!
    
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - Setting Detail Data
        if let isFav = tvShow.isFavourite {
            //NavBarItem
            //Cuando ya tiene algun valor isFavorite del Show
            if isFav {
                FavoriteBarButton.title = "Delete"
            } else {
                FavoriteBarButton.title = "+ Favorite"
            }
        } else {
            //Cuando no se ha agregado antes (isFavorite = nil)
            FavoriteBarButton.title = "Favorite"
        }
        //MARK: - Setting Show's Image
        guard let imageUrl = tvShow.show?.image?.original,
              let url = URL(string: imageUrl) else {return}
        DetailImageView.kf.setImage(with: Source.network(url))
        //Summary
        if let summary = tvShow.summary {
            let formatedSummary = summary.replacingOccurrences(of: "<p>",with: "")
            let lastFormated = formatedSummary.replacingOccurrences(of: "\"</p>",with: "")
            SummaryTextView.text = lastFormated
        } else {
            SummaryTextView.text = "You caught us!\nNo show desciption available."
        }
        //Show Type
        if let type = tvShow.show?.type {
            TypeLabel.text = "Show type: \(type)"
        } else {
            TypeLabel.text = "No type description available"
        }
        //Show Shedule
        if let days = tvShow.show?.schedule?.days,
           let airtime = tvShow.show?.schedule?.time {
            var text = ""
            for day in days {
                if day == days.last{
                    text.append(day.lowercased())
                } else {
                    text.append(day.lowercased())
                    text.append(", ")
                }
            }
            ScheduleTextView.text = "On air \(text) at \(airtime)"
        }
        //IMDB Endpoint
        guard let imdbEndPoint = tvShow.show?.externals?.imdb as? String else {
            ImdbButton.isHidden = true
            return
        }
        endpoint = imdbEndPoint
        
    }
    
    //MARK: - IBActions
    //NavigationBarBUtton
    @IBAction func BarButtonPressed(_ sender: Any) {
        
        if let isFav = tvShow.isFavourite {
            //Cuando ya tiene algun valor
            if isFav {
                //Cuando ya es favorito, isFavorite = true
                let alertController = UIAlertController(title: "Attention!", message: "You're about to erase a TV Show from Favorites Catalog", preferredStyle: .alert)
                //Borrar
                alertController.addAction(UIAlertAction(title: "Accept", style: .destructive, handler: { action in
                    //Borrar celda y actualizar arreglo
                    favoriteTvShows.remove(at: favoriteTvShows.firstIndex(where: {$0.id == self.tvShow.id})!)
                    self.tvShow.isFavourite = false
                    self.FavoriteBarButton.title = "Favorite"
                    self.ViewControllerInstance.persistFavorites()
                    
                }))
                //Nada
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                }))
                present(alertController, animated: true)
            } else {
                //Cuando no es favorito, isFavorite = false
                
                showAlert(message: "Se agregará a lista de favoritos")
                favoriteTvShows.append(self.tvShow)
                self.tvShow.isFavourite = true
                FavoriteBarButton.title = "Delete"
                
                ViewControllerInstance.persistFavorites()
                
            }
        } else {
            //Cuando no se ha agregado antes isFavorite = nil
            showAlert(message: "Se agregará a lista de favoritos")
            favoriteTvShows.append(self.tvShow)
            self.tvShow.isFavourite = true
            FavoriteBarButton.title = "Delete"
            
            ViewControllerInstance.persistFavorites()
            
        }
    }
    //IMDBButton
    @IBAction func ImdbButtonPressed(_ sender: UIButton) {
        let url = urlImdb + endpoint
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    func showAlert(message:String){
        let alertController = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Accept", style: .default))
        present(alertController, animated: true)
    }

}























