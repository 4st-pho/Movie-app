import Foundation
import RealmSwift


class MovieDTO: Object, Codable {
    @Persisted var id: String?
    @Persisted var title: String?
    @Persisted var imageURL: String?
    @Persisted var rating: String?
    @Persisted var duration: String?
    @Persisted var cast: List<Cast>
    @Persisted var categories: List<Cast>
    @Persisted var _description: String?
    @Persisted var contentRating: String?
    @Persisted var videoLink: String?
    @Persisted var language: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case imageURL = "imageUrl"
        case _description = "description"
        case rating, duration, cast, categories, contentRating, videoLink, language
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(rating, forKey: .rating)
        try container.encode(duration, forKey: .duration)
        try container.encode(_description, forKey: ._description)
        try container.encode(contentRating, forKey: .contentRating)
        try container.encode(videoLink, forKey: .videoLink)
        try container.encode(language, forKey: .language)
    }
    
    required convenience init(from decoder: Decoder) throws {
            self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(Persisted<String?>.self, forKey: .id)
        self._title = try container.decode(Persisted<String?>.self, forKey: .title)
        self._imageURL = try container.decode(Persisted<String?>.self, forKey: .imageURL)
        self.__description = try container.decode(Persisted<String?>.self, forKey: ._description)
        self._rating = try container.decode(Persisted<String?>.self, forKey: .rating)
        self._duration = try container.decode(Persisted<String?>.self, forKey: .duration)
        self._cast = try container.decode(Persisted<List<Cast>>.self, forKey: .cast)
        self._categories = try container.decode(Persisted<List<Cast>>.self, forKey: .categories)
        self._contentRating = try container.decode(Persisted<String?>.self, forKey: .contentRating)
        self._videoLink = try container.decode(Persisted<String?>.self, forKey: .videoLink)
        self._language = try container.decode(Persisted<String?>.self, forKey: .language)
    }
}

// MARK: - Cast
class Cast: Object, Codable {
    @Persisted var id: String?
    @Persisted var name: String?
    @Persisted var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, avatar
    }
}

extension MovieDTO {
    func toDomain() -> Movie{
        Movie(
            id: id ?? "" ,
            name: title ?? "",
            imageUrl: imageURL ?? "",
            rating: rating ?? "",
            categories: categories.map{$0.name ?? ""},
            duration: duration ?? "",
            description : _description ?? "",
            cast: cast.map(){ actor in
                return Actor(id: actor.id ?? "", name: actor.name ?? "", avatar: actor.avatar ?? "")
            },
            contentRating: contentRating ?? "",
            language: language ?? "",
            videoLink: videoLink ?? ""
        )
    }
}
