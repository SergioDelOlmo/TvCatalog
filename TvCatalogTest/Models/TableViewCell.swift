//
//  TableViewCell.swift
//  TvCatalogTest
//
//  Created by Sergio Del Olmo Aguilar on 29/11/22.
//

import UIKit
import Kingfisher

class TableViewCell: UITableViewCell {
    //MARK: - UIElements
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var ImageShow: UIImageView!
    @IBOutlet weak var LabelShowName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func drawData(model:TableViewCellProtocol){
        //Setting Show's Image and Name
        if let tvShow = model as? TvShow {
            LabelShowName.text = tvShow.getShowName()
            guard let imageUrl = tvShow.getImageUrl() else {return}
            let url = URL(string: imageUrl)
            ImageShow.kf.setImage(with: Source.network(url!))
        } else {
            ImageShow.image = UIImage()
        }
    }
    
}
