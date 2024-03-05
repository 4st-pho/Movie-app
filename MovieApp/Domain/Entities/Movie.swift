import Foundation

class Movie{
    var id: String
    var name: String
    var imageUrl: String
    var rating: String
    var categories: [String]
    var duration: String
    var description: String
    var cast: [Actor]
    var contentRating : String
    var language : String
    var videoLink : String
    var comments: [Comment] = []
    
    init(id: String = "", name: String, imageUrl: String, rating: String, categories: [String], duration: String, description: String, cast: [Actor], contentRating: String, language: String, videoLink: String) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.rating = rating
        self.categories = categories
        self.duration = duration
        self.description = description
        self.cast = cast
        self.contentRating = contentRating
        self.language = language
        self.videoLink = videoLink
        
    }
}
