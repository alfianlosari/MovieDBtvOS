//
//  MovieCell.swift
//  MovieDBTV
//
//  Created by Alfian Losari on 23/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var unfocusedConstraint: NSLayoutConstraint!
    var focusedConstraint: NSLayoutConstraint!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        focusedConstraint = titleLabel.topAnchor.constraint(equalTo: imageView.focusedFrameGuide.bottomAnchor, constant: 16)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        focusedConstraint?.isActive = isFocused
        unfocusedConstraint?.isActive = !isFocused
    }
    
    func configure(_ movie: Movie) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: movie.posterURL)
        
        titleLabel.text = movie.title
        
        if movie.ratingText.isEmpty {
            ratingLabel.text = dateFormatter.string(from: movie.releaseDate)
        } else {
            ratingLabel.text = movie.ratingText

        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        setNeedsUpdateConstraints()
        coordinator.addCoordinatedAnimations({
            self.layoutIfNeeded()
        }, completion: nil)
    }    
}
