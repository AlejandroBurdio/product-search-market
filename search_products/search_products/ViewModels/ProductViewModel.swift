import Foundation
import SwiftUI

@MainActor
class ProductViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var selectedProduct: Product?
    @Published var showingProductDetail = false
    
    private var totalCount = 0
    private let pageSize = 24
    
    func searchProducts(resetResults: Bool = true) async {
        guard !searchText.isEmpty else { return }
        
        if resetResults {
            products = []
            currentPage = 1
            hasMorePages = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await ProductService.shared.searchProducts(
                query: searchText,
                page: currentPage
            )
            
            if resetResults {
                products = response.products
            } else {
                products.append(contentsOf: response.products)
            }
            
            totalCount = response.count
            hasMorePages = products.count < totalCount
            currentPage += 1
            
        } catch ProductServiceError.rateLimitExceeded {
            errorMessage = "Demasiadas peticiones. Por favor, espera un momento."
        } catch ProductServiceError.networkError(_) {
            errorMessage = "Error de conexión. Verifica tu internet."
        } catch {
            errorMessage = "Error al buscar productos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadMoreContentIfNeeded(currentProduct product: Product) async {
        guard let lastProduct = products.last,
              lastProduct.id == product.id,
              hasMorePages,
              !isLoading else {
            return
        }
        
        await searchProducts(resetResults: false)
    }
    
    func getProductDetails(for barcode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let product = try await ProductService.shared.getProductDetails(barcode: barcode)
            selectedProduct = product
            showingProductDetail = true
        } catch {
            errorMessage = "Error al cargar los detalles del producto"
        }
        
        isLoading = false
    }
} 