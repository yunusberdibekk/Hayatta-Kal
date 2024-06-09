//
//  Home.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

enum Home: String, CaseIterable {
    case beforeTheEarthquake
    case duringAnEarthquake
    case afterTheEarthquake
    case earthquakeBag

    var title: String {
        switch self {
        case .beforeTheEarthquake:
            "Depremden Önce Yapılması Gerekenler"
        case .duringAnEarthquake:
            "Depremden Anında Yapılması Gerekenler"
        case .afterTheEarthquake:
            "Depremden Sonra Yapılması Gerekenler"
        case .earthquakeBag:
            "Depremden Çantasında Ne Bulundurulmalı?"
        }
    }

    var description: String {
        switch self {
        case .beforeTheEarthquake:
            "Deprem öncesi alınması gereken önlemler ve yapılması gereken hazırlıklar, olası bir depremin etkilerini azaltmak ve can kayıplarını önlemek adına oldukça önemlidir. İşte deprem öncesi yapılması gerekenler:"
        case .duringAnEarthquake:
            "Deprem sırasında yapılması gerekenler, deprem anında hayatta kalmak ve yaralanmalardan kaçınmak için oldukça önemlidir. İşte deprem sırasında yapılması gerekenler:"
        case .afterTheEarthquake:
            "Deprem sonrasında yapılması gerekenler, güvenliğinizi sağlamak ve olası tehlikeleri önlemek adına oldukça önemlidir. İşte deprem sonrasında yapılması gerekenler:"
        case .earthquakeBag:
            "Deprem çantası, olası bir deprem durumunda hayatta kalmanızı ve temel ihtiyaçlarınızı karşılamanızı sağlayacak malzemeleri içermelidir. İşte deprem çantasında bulundurulması gereken temel malzemeler:"
        }
    }

    var url: String { "" }
    
    var image:String {
        SFSymbol.fileMenuAndSelection.rawValue
    }
}
