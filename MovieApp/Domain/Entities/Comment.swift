class Comment{
    let id: String
    let movieId: String
    let user: User
    let content: String
    
    init(id: String, movieId: String, user: User, content: String) {
        self.id = id
        self.movieId = movieId
        self.user = user
        self.content = content
    }
}
