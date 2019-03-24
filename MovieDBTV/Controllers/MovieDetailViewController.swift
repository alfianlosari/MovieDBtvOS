//
//  MovieDetailViewController.swift
//  MovieDBTV
//
//  Created by Alfian Losari on 23/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import Kingfisher
import XCDYouTubeKit
import AVKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var movieService: MovieService = MovieStore.shared
    
    var movieId: Int!
    private var movie: Movie! {
        didSet {
            updateMovieDetail()
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MovieDetailCell.nib, forCellReuseIdentifier: "DetailCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        fetchMovieDetail()
    }
    
    private func fetchMovieDetail() {
        
        guard let movieId = movieId else {
            return
        }
        
        activityIndicator.startAnimating()
        hideError()
        
        movieService.fetchMovie(id: movieId, successHandler: {[weak self] (movie) in
            self?.activityIndicator.stopAnimating()
            self?.movie = movie
        }) { [weak self] (error) in
            self?.activityIndicator.stopAnimating()
            self?.showError(error.localizedDescription)
        }
    }
        
    private func updateMovieDetail() {
        guard let movie = movie else {
            return
        }
        
        titleLabel.text = movie.title
        ratingLabel.text = movie.ratingText
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: movie.posterURL)

        tableView.reloadData()
    }
    
    private func showError(_ error: String) {
        infoLabel.text = error
        infoLabel.isHidden = false
        refreshButton.isHidden = false
    }
    
    private func hideError() {
        infoLabel.isHidden = true
        refreshButton.isHidden = true
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        fetchMovieDetail()
    }
}

extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movie == nil ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return movie?.videos?.results.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! MovieDetailCell
            cell.movie = movie
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let video = (movie?.videos?.results ?? [])[indexPath.row]
            cell.textLabel?.text = video.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let video = (movie?.videos?.results ?? [])[indexPath.row]
            let playerVC = AVPlayerViewController()
            
            present(playerVC, animated: true, completion: nil)
            XCDYouTubeClient.default().getVideoWithIdentifier(video.key) {[weak self, weak playerVC] (video, error) in
                if let _ = error {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                guard let video = video else {
                    self?.dismiss(animated: true, completion: nil)

                    return
                }
                
                let streamURL: URL
                if let url = video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]  {
                    streamURL = url
                } else if let url = video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] {
                    streamURL = url
                } else if let url = video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                    streamURL = url
                } else if let urlDict = video.streamURLs.first {
                    streamURL = urlDict.value
                } else {
                    self?.dismiss(animated: true, completion: nil)

                    return
                }
                playerVC?.player = AVPlayer(url: streamURL)
                playerVC?.player?.play()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Trailers"
        }
        return nil
    }
    
}
