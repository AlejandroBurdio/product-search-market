import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let productName: String
    let brands: String?
    let quantity: String?
    let imageUrl: String?
    let price: Double?
    let nutritionGrades: String?
    let nutriments: Nutriments?
    let categories: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case productName = "product_name"
        case brands
        case quantity
        case imageUrl = "image_url"
        case price
        case nutritionGrades = "nutrition_grades"
        case nutriments
        case categories = "categories_tags"
    }
}

struct Nutriments: Codable {
    let energy: Double?
    let proteins: Double?
    let carbohydrates: Double?
    let fat: Double?
    let sugar: Double?
    let salt: Double?
    
    enum CodingKeys: String, CodingKey {
        case energy = "energy-kcal_100g"
        case proteins = "proteins_100g"
        case carbohydrates = "carbohydrates_100g"
        case fat = "fat_100g"
        case sugar = "sugars_100g"
        case salt = "salt_100g"
    }
}

struct ProductResponse: Codable {
    let count: Int
    let page: Int
    let pageSize: Int
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case count
        case page
        case pageSize = "page_size"
        case products
    }
} 