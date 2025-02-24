import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Imagen y detalles básicos
                productHeader
                
                // Información nutricional
                if let nutriments = product.nutriments {
                    nutritionalInfo(nutriments)
                }
                
                // Categorías
                if let categories = product.categories, !categories.isEmpty {
                    categoriesSection(categories)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let imageUrl = product.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                }
                .frame(maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.productName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let brands = product.brands {
                    Text(brands)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let quantity = product.quantity {
                    Text(quantity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let grade = product.nutritionGrades?.uppercased() {
                    HStack {
                        Text("Nutri-Score:")
                        Text(grade)
                            .font(.headline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(nutritionGradeColor(grade))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private func nutritionalInfo(_ nutriments: Nutriments) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información Nutricional")
                .font(.headline)
            
            VStack(spacing: 12) {
                nutritionRow("Energía", value: nutriments.energy, unit: "kcal")
                nutritionRow("Proteínas", value: nutriments.proteins, unit: "g")
                nutritionRow("Carbohidratos", value: nutriments.carbohydrates, unit: "g")
                nutritionRow("Grasas", value: nutriments.fat, unit: "g")
                nutritionRow("Azúcares", value: nutriments.sugar, unit: "g")
                nutritionRow("Sal", value: nutriments.salt, unit: "g")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func nutritionRow(_ title: String, value: Double?, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let value = value {
                Text(String(format: "%.1f %@", value, unit))
                    .foregroundColor(.secondary)
            } else {
                Text("N/A")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func categoriesSection(_ categories: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categorías")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Text(category.replacingOccurrences(of: "en:", with: ""))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func nutritionGradeColor(_ grade: String) -> Color {
        switch grade {
        case "A": return .green
        case "B": return .blue
        case "C": return .yellow
        case "D": return .orange
        case "E": return .red
        default: return .gray
        }
    }
}

// Helper view para mostrar las categorías en flujo
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: result.xs[index], y: result.ys[index])
            subview.place(at: point, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var height: CGFloat = 0
        var xs: [CGFloat] = []
        var ys: [CGFloat] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                xs.append(x)
                ys.append(y)
                
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }
            
            height = y + maxHeight
        }
    }
} 