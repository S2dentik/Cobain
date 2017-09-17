extension String {
    var first: Character? {
        return characters.first
    }
    
    var droppingFirst: String {
        return String(characters.dropFirst())
    }
}
