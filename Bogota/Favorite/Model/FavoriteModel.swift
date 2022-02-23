//
//  FavoriteModel.swift
//  bogota
//
//  Created by 전현성 on 2022/02/23.
//

import Foundation

enum FavoriteType: Codable {
    case station
    case bus
}

struct FavoriteModel: Codable {
    var type: FavoriteType?
    
    var stationName: String?
    var arsId: String?
    
    var busRoute: BusRoute?
    var busInfo: LowBusInfo?
}

class Favorite: NSObject {
    static let shared = Favorite()
    
    func saveFavorite(_ saveFavorite: FavoriteModel) {
        if var favorites = loadFavorite() {
            if checkContains(saveFavorite) == false {
                favorites.insert(saveFavorite, at: 0)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: "favorite")
            }
        } else {
            let favorites = [saveFavorite]
            UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: "favorite")
        }
    }
    
    func loadFavorite() -> [FavoriteModel]? {
        if let favoriteData = UserDefaults.standard.value(forKey: "favorite") as? Data {
            do {
                let favorites = try PropertyListDecoder().decode([FavoriteModel].self, from: favoriteData)
                return favorites
            } catch {
                print("Decode error : search history")
            }
        }
        return nil
    }
    
    func deleteFavorite(_ saveFavorite: FavoriteModel) {
        var favorites = loadFavorite()
        var findIndex: Int?
        
        favorites?.enumerated().forEach({ index, favorite in
            if saveFavorite.type == .station && favorite.arsId == saveFavorite.arsId {
                findIndex = index
            } else if saveFavorite.type == .bus && favorite.busRoute?.busRouteId == saveFavorite.busRoute?.busRouteId && favorite.busInfo?.busRouteId == saveFavorite.busInfo?.busRouteId {
                findIndex = index
            }
        })
        
        if let findIndex = findIndex {
            favorites?.remove(at: findIndex)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: "favorite")
        }
    }
    
    func checkContains(_ saveFavorite: FavoriteModel) -> Bool {
        var isContains = false
        let favorites = loadFavorite()
        
        favorites?.forEach({ favorite in
            if saveFavorite.type == .station && favorite.arsId == saveFavorite.arsId {
                isContains = true
            } else if saveFavorite.type == .bus && favorite.busRoute?.busRouteId == saveFavorite.busRoute?.busRouteId && favorite.busInfo?.busRouteId == saveFavorite.busInfo?.busRouteId {
                isContains = true
            }
        })
        
        return isContains
    }
}
