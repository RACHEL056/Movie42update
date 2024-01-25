//
//  Reservation.swift
//  Movie42_MVVM
//
//  Created by 김우경 on 1/19/24.
//

import Foundation

struct Reservation: Codable {
    var movieTitle: String
    var date: Date
    var time: String
    var numberOfTickets: Int 
    

    init(movieTitle: String, date: Date, time: String, numberOfTickets: Int) {
        self.movieTitle = movieTitle
        self.date = date
        self.time = time
        self.numberOfTickets = numberOfTickets
    }
}
