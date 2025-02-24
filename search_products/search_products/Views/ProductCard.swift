import SwiftUI

struct ProductCard: View {
    let product: Product
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        Button(action: {
            Task {
                await viewModel.getProductDetails(for: product.id)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                if let imageUrl = product.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    if let brands = product.brands {
                        Text(brands.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(product.productName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    if let grade = product.nutritionGrades?.uppercased() {
                        Text("Nutri-Score: \(grade)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    if let price = product.price {
                        Text(String(format: "%.2f €", price))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    if let quantity = product.quantity {
                        Text(quantity)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .task {
                await viewModel.loadMoreContentIfNeeded(currentProduct: product)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $viewModel.showingProductDetail) {
            if let selectedProduct = viewModel.selectedProduct {
                NavigationView {
                    ProductDetailView(product: selectedProduct)
                        .navigationBarItems(trailing: Button("Cerrar") {
                            viewModel.showingProductDetail = false
                        })
                }
            }
        }
    }
} 