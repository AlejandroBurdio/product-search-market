import Foundation

enum ProductServiceError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case rateLimitExceeded
}

class ProductService {
    static let shared = ProductService()
    private let baseURL = "https://world.openfoodfacts.org/api/v2"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": "SearchProducts/1.0 (alejandro.burdio@example.com)"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func searchProducts(query: String, page: Int = 1) async throws -> ProductResponse {
        var components = URLComponents(string: "\(baseURL)/search")
        
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: "24"),
            URLQueryItem(name: "fields", value: [
                "code",
                "product_name",
                "brands",
                "quantity",
                "image_url",
                "nutrition_grades",
                "nutriments",
                "categories_tags"
            ].joined(separator: ","))
        ]
        
        guard let url = components?.url else {
            throw ProductServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProductServiceError.serverError("Respuesta inválida del servidor")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                return try decoder.decode(ProductResponse.self, from: data)
            case 429:
                throw ProductServiceError.rateLimitExceeded
            default:
                throw ProductServiceError.serverError("Error del servidor: \(httpResponse.statusCode)")
            }
        } catch let error as DecodingError {
            throw ProductServiceError.decodingError(error)
        } catch {
            throw ProductServiceError.networkError(error)
        }
    }
    
    func getProductDetails(barcode: String) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/product/\(barcode)") else {
            throw ProductServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProductServiceError.serverError("Respuesta inválida del servidor")
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ProductDetailResponse.self, from: data)
                return response.product
            } else {
                throw ProductServiceError.serverError("Error del servidor: \(httpResponse.statusCode)")
            }
        } catch {
            throw ProductServiceError.networkError(error)
        }
    }
}

// Estructura auxiliar para la respuesta de detalles del producto
private struct ProductDetailResponse: Codable {
    let product: Product
    let status: Int
    let statusVerbose: String
    
    enum CodingKeys: String, CodingKey {
        case product
        case status
        case statusVerbose = "status_verbose"
    }
} 