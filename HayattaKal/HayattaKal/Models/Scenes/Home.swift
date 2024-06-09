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
        currentModel.title
    }

    var headline: String {
        currentModel.headline
    }

    var currentModel: HomeDetailModel {
        switch self {
        case .beforeTheEarthquake:
            HomeDetailModel.homeDetailItems[0]
        case .duringAnEarthquake:
            HomeDetailModel.homeDetailItems[1]
        case .afterTheEarthquake:
            HomeDetailModel.homeDetailItems[2]
        case .earthquakeBag:
            HomeDetailModel.homeDetailItems[3]
        }
    }

    var url: String { "" }

    var image: String {
        SFSymbol.fileMenuAndSelection.rawValue
    }
}

struct HomeDetailModel: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let headline: String
    let description: [String]

    static let homeDetailItems: [HomeDetailModel] = [
        HomeDetailModel(
            title: "Depremden Önce Yapılması Gerekenler",
            headline: "Deprem öncesi alınması gereken önlemler ve yapılması gereken hazırlıklar, olası bir depremin etkilerini azaltmak ve can kayıplarını önlemek adına oldukça önemlidir. İşte deprem öncesi yapılması gerekenler:",
            description: [
                "1. Deprem Planı Hazırlayın: Aile bireyleriyle birlikte bir deprem planı oluşturun. Toplanma noktalarını belirleyin ve deprem sırasında ne yapmanız gerektiğini önceden planlayın.",
                "2. Acil Durum Çantası Hazırlayın: Su, yiyecek, el feneri, ilk yardım malzemeleri, ilaçlar, radyo, piller, battaniye, kıyafetler ve önemli belgeleri içeren bir acil durum çantası hazırlayın ve kolayca ulaşabileceğiniz bir yerde saklayın.",
                "3. Bina Güvenliğini Sağlayın: Ev ve iş yerinizin depreme dayanıklı olup olmadığını kontrol ettirin. Gerekirse güçlendirme çalışmaları yaptırın.",
                "4. Mobilya ve Eşyaları Sabitleyin: Ağır mobilya ve eşyaları duvarlara sabitleyin., Raflardaki eşyaları düşmeyecek şekilde düzenleyin.",
                "5. Elektrik, Gaz ve Su Vanalarını Öğrenin: Acil bir durumda elektrik, gaz ve su vanalarını kapatmayı öğrenin ve bu vanaların yerlerini aile bireylerine de öğretin.",
                "6. İlk Yardım Eğitimi Alın: İlk yardım eğitimi alın ve temel ilk yardım bilgilerini öğrenin.",
                "7. Yangın Söndürücü Bulundurun: Evde ve iş yerinde yangın söndürücü bulundurun ve nasıl kullanılacağını öğrenin.",
                "8. Deprem Sigortası Yaptırın: Ev ve iş yerinizi deprem sigortası ile güvence altına alın.",
                "9. Toplanma Alanlarını Öğrenin: Mahallenizdeki toplanma alanlarını öğrenin ve buralara nasıl ulaşabileceğinizi belirleyin.",
                "10. Telefon Listesi Hazırlayın: Acil durumlar için aileniz ve yakınlarınızla iletişime geçebileceğiniz telefon numaralarının bulunduğu bir liste hazırlayın."

            ]),

        HomeDetailModel(
            title: "Deprem Sırasında Yapılması Gerekenler",
            headline: "Deprem sırasında yapılması gerekenler, deprem anında hayatta kalmak ve yaralanmalardan kaçınmak için oldukça önemlidir. İşte deprem sırasında yapılması gerekenler:",
            description: [
                "1. Sakin Olun: Panik yapmayın ve sakin kalmaya çalışın. Panik, yanlış hareketler yapmanıza neden olabilir.",
                "2. Güvenli Bir Yer Bulun: İç mekandaysanız, çömelip, başınızı koruyacak bir pozisyonda durun ve sağlam bir eşya altına girin (çalışma masası gibi). Eğer masa yoksa, iç duvarların köşelerine yakın durun ve başınızı ve boynunuzu ellerinizle koruyun.",
                "3. Başınızı ve Boynunuzu Koruyun: Düşen nesnelere karşı başınızı ve boynunuzu ellerinizle koruyun. Bu, yaralanma riskini azaltır.",
                "4. Cam ve Pencerelerden Uzak Durun: Cam ve pencerelerden, aynalardan ve düşebilecek ağır nesnelerden uzak durun. Bu tür nesneler kırılarak veya düşerek yaralanmalara neden olabilir.",
                "5. Merdivenleri ve Asansörleri Kullanmayın: Merdivenler ve asansörler deprem sırasında güvenli değildir. Asansördeyseniz, en yakın katta inin.",
                "6. Dışarıdaysanız Açık Alanlara Çıkın: Dış mekandaysanız, binalardan, ağaçlardan, sokak lambalarından ve elektrik tellerinden uzak, açık bir alana gidin. Yıkılabilecek yapılardan uzak durun.",
                "7. Araç Kullanıyorsanız Dikkatli Olun: Araç içindeyseniz, güvenli bir şekilde durun ve araç içinde kalın. Köprüler, tüneller ve üst geçitlerden uzak durun. Deprem durduktan sonra dikkatli bir şekilde hareket edin.",
                "8. Deniz Kıyısındaysanız: Deprem sonrası tsunami riski olabilir. Denizden uzaklaşın ve yüksek yerlere çıkın.",
                "9. Gaza ve Ateşe Dikkat Edin: Deprem sonrasında gaz kaçakları ve yangınlar olabilir. Çakmak veya kibrit kullanmayın ve elektrik anahtarlarını açıp kapatmayın."
            ]),

        HomeDetailModel(
            title: "Depremden Sonra Yapılması Gerekenler",
            headline: "Deprem sonrasında yapılması gerekenler, güvenliğinizi sağlamak ve olası tehlikeleri önlemek adına oldukça önemlidir. İşte deprem sonrasında yapılması gerekenler:",
            description: [
                " 1. Sakin Kalın: Panik yapmayın ve sakinliğinizi koruyun. Düşünceli ve dikkatli hareket edin.",
                " 2. Yaralıları Kontrol Edin: Öncelikle kendinizi ve çevrenizdeki insanların yaralı olup olmadığını kontrol edin. İlk yardım eğitiminiz varsa, gerektiğinde ilk yardım uygulayın.",
                " 3. Artçı Sarsıntılara Dikkat Edin: Deprem sonrasında artçı sarsıntılar olabilir. Güvenli bir yerde bekleyin ve artçı sarsıntılara karşı dikkatli olun.",
                " 4. Yaralıları ve Tehlikeleri Bildirin: Ağır yaralılar ve tehlikeli durumlar için acil durum numaralarını arayın ve yetkililere bilgi verin.",
                " 5. Bina Güvenliğini Kontrol Edin: Binanızın yapısal olarak güvenli olup olmadığını kontrol edin.Çatlaklar veya hasarlar varsa, binadan çıkın ve güvenli bir alana geçin.",
                " 6. Gaz ve Elektrik Vanalarını Kontrol Edin: Gaz sızıntısı veya elektrik arızası olup olmadığını kontrol edin. Gaz kokusu alıyorsanız, vanayı kapatın, binayı terk edin ve yetkililere haber verin. Elektrik arızaları için ana şalteri kapatın.",
                " 7. Temiz Su ve Gıda Tüketin: Su borularının zarar görmüş olabileceğini unutmayın. Temiz su ve güvenli gıda tüketmeye özen gösterin.",
                " 8. Acil Durum Çantasını Kullanma: Deprem öncesi hazırladığınız acil durum çantasını kullanın. Su, yiyecek, el feneri ve diğer acil ihtiyaçlarınızı buradan karşılayın.",
                " 9. Radyo ve İnternetten Bilgi Alın: Yetkililerin ve haber kaynaklarının bilgilendirmelerini takip edin. Acil durum talimatlarını ve güvenlik uyarılarını dikkate alın.",
                " 10. Güvenli Toplanma Alanlarına Gidin: Önceden belirlenen güvenli toplanma alanlarına gidin. Buralarda yetkililerden yardım ve yönlendirme alabilirsiniz.",
                " 11. Çevrenize Yardımcı Olun: Mümkünse komşularınıza ve çevrenizdeki insanlara yardımcı olun. Özellikle yaşlılar, çocuklar ve engellilere destek olun.",
                " 12. Hasarlı Binalara Girmeyin: Ağır hasar görmüş binalara tekrar girmeyin. Bu binalar çökme riski taşıyabilir.",
                " 13. Telefon Hatlarını Meşgul Etmeyin: Acil durumlar dışında telefon hatlarını meşgul etmeyin. Acil durum ekiplerinin iletişimi için hatların açık kalmasını sağlayın.",
                " 14. Ulaşımı ve Trafiği Dikkatli Kullanın: Zorunlu olmadıkça araç kullanmayın ve acil durum ekiplerinin geçişlerini engellemeyin."
            ]),

        HomeDetailModel(
            title: "Deprem Çantasında Ne Bulundurulmalı?",
            headline: "Deprem çantası, olası bir deprem durumunda hayatta kalmanızı ve temel ihtiyaçlarınızı karşılamanızı sağlayacak malzemeleri içermelidir. İşte deprem çantasında bulundurulması gereken temel malzemeler:",
            description: [
                "1. Su: Kişi başına en az 3 gün yetecek miktarda içme suyu.",
                "2. Gıda: Bozulmayan, uzun ömürlü yiyecekler (konserve yiyecekler, enerji barları, kuru meyveler).",
                "3. İlk Yardım Malzemeleri: İlk yardım kiti (bandaj, gazlı bez, antiseptik mendil, makas, yapışkan bant, pamuk, eldiven, yara bandı). Kişisel ilaçlar (düzenli olarak kullanılan reçeteli ilaçlar ve temel ağrı kesiciler).",
                "4. Giysi ve Koruyucu Ekipman: Yedek kıyafetler (mevsime uygun giysiler, iç çamaşırı, çorap). Yağmurluk,battaniye veya acil durum örtüsü.",
                "5. Hijyen Malzemeleri: Islak mendil veya dezenfektan.Sabun, diş fırçası, diş macunu. Tuvalet kağıdı, hijyenik ped veya tampon.",
                "6. Aydınlatma ve Enerji Kaynakları: El feneri ve yedek piller.Şarj edilebilir piller ve taşınabilir şarj cihazı (powerbank). Kibrit veya çakmak.",
                "7. Çok Amaçlı Araç Gereçler: Düdük (yardım çağırmak için). Acil durum battaniyesi.",
                "8. Kişisel Belgeler ve Nakit Para: Kimlik belgeleri (nüfus cüzdanı, pasaport, ehliyet). Önemli evrakların fotokopileri (sigorta poliçeleri, tapular, sağlık kayıtları). Bir miktar nakit para ve küçük bozuk paralar.",
                "9. İletişim Araçları: Pil ile çalışan veya el ile kurulan radyo. Önemli telefon numaralarının yazılı olduğu bir liste.",
                "10. Diğer Gerekli Malzemeler: Dayanıklı ayakkabılar. Eldiven. İpli veya fermuarlı torbalar (çöp torbası, su geçirmez torba). Maske (toz ve kirden korunmak için). Kağıt ve kalem. Temel tamir aletleri (tornavida, pense)."
            ])
    ]
}
