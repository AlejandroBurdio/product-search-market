//
//  ContentView.swift
//  search_products
//
//  Created by Alejandro Burdio on 23/2/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Buscador
                    searchBar
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if !viewModel.products.isEmpty {
                        productsSection
                    }
                    
                    // Gráfico de supermercados
                    supermarketSection
                    
                    // Consejos de compra
                    shoppingTipsSection
                }
            }
            .navigationTitle("Comparador de Precios")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Buscar productos...", text: $viewModel.searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await viewModel.searchProducts()
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 5)
        }
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resultados")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.products) { product in
                        ProductCard(product: product, viewModel: viewModel)
                            .frame(width: 180)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var supermarketSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Comparativa de Precios")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("2024")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Índice de precios por supermercado")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Base 100 = Mercadona")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach([
                        ("Alcampo", 97.8, Color.green),
                        ("Lidl", 98.5, Color.yellow),
                        ("Mercadona", 100.0, Color.blue),
                        ("Carrefour", 101.2, Color.orange),
                        ("Eroski", 102.8, Color.purple),
                        ("Dia", 103.5, Color.red),
                        ("Consum", 104.2, Color.mint)
                    ], id: \.0) { supermercado, precio, color in
                        BarMark(
                            x: .value("Precio", precio),
                            y: .value("Supermercado", supermercado)
                        )
                        .foregroundStyle(color.gradient)
                        .annotation(position: .trailing) {
                            Text(String(format: "%.1f", precio))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .frame(width: 350, height: 300)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Fuente: OCU - Estudio de Supermercados 2024")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var shoppingTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consejos para Ahorrar")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach([
                    (icon: "cart", text: "Haz una lista de compra", color: Color.blue),
                    (icon: "tag", text: "Compara precios por unidad", color: Color.green),
                    (icon: "calendar", text: "Aprovecha las ofertas", color: Color.orange),
                    (icon: "clock", text: "Elige el mejor momento", color: Color.purple)
                ], id: \.text) { tip in
                    TipRow(icon: tip.icon, text: tip.text, color: tip.color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(text)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
