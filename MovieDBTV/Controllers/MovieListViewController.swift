//
//  MovieListViewController.swift
//  MovieDBTV
//
//  Created by Alfian Losari on 23/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var refreshButton: UIButton!
    
    var endpoint: Endpoint?
    var movieService: MovieService = MovieStore.shared
    var movies = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MovieCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        fetchMovies()
    }
    
    private func fetchMovies() {
        guard let endpoint = endpoint else {
            return
        }
        
        activityIndicator.startAnimating()
        hideError()
        
        movieService.fetchMovies(from: endpoint, params: nil, successHandler: { [unowned self] (response) in
            self.activityIndicator.stopAnimating()
            self.movies = response.results
        }) { [unowned self] (error) in
            self.activityIndicator.stopAnimating()
            self.showError(error.localizedDescription)
        }
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
        fetchMovies()
    }
}

extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.item]
        cell.configure(movie)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailVC = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        
        movieDetailVC.movieId = movies[indexPath.item].id
        present(movieDetailVC, animated: true, completion: nil)
    }
    
}

extension MovieListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        movies = []

        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        
        activityIndicator.startAnimating()
        hideError()
        
        movieService.searchMovie(query: text, params: nil, successHandler: {[unowned self] (response) in
            self.activityIndicator.stopAnimating()
            
            if searchController.searchBar.text == text {
                self.movies = response.results
            }
        }) { [unowned self] (error) in
            self.activityIndicator.stopAnimating()
            self.showError(error.localizedDescription)
        }
        
    }
    
}


