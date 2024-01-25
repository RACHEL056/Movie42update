//
//  UserSettings.swift
//  Movie42_MVVM
//
//  Created by 김우경 on 1/20/24.
//

import Foundation

class UserSettings {
    static let shared = UserSettings()

    private let heartSelectedKey = "isHeartSelected"

    func saveHeartSelectedState(_ isSelected: Bool, for movie: Movie) {
        let key = "\(heartSelectedKey)_\(movie.id)"
        UserDefaults.standard.set(isSelected, forKey: key)
    }

    func loadHeartSelectedState(for movie: Movie) -> Bool {
        let key = "\(heartSelectedKey)_\(movie.id)"
        return UserDefaults.standard.bool(forKey: key)
    }
}
