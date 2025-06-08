import SwiftUI
import CoreML
import Vision
import AVFoundation

// MARK: - Design System
struct DesignSystem {
    // Colores para adultos mayores
    static let primaryBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let primaryGreen = Color(red: 0.2, green: 0.6, blue: 0.3)
    static let warningOrange = Color(red: 0.9, green: 0.5, blue: 0.1)
    static let dangerRed = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let backgroundCream = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let cardBackground = Color.white
    
    // Tipografía grande y clara
    static let hugeTitle = Font.system(size: 32, weight: .bold)
    static let titleFont = Font.system(size: 24, weight: .semibold)
    static let bodyFont = Font.system(size: 20, weight: .medium)
    static let smallFont = Font.system(size: 18, weight: .regular)
    static let captionFont = Font.system(size: 16, weight: .regular)
}

// MARK: - Botón Senior-Friendly Principal
struct SeniorFriendlyButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    let backgroundColor: Color
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 80
            case .large: return 100
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        backgroundColor: Color,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: size.fontSize + 4, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: size.fontSize - 4))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .frame(minHeight: size.height)
        .accessibility(label: Text(title))
        .accessibility(hint: Text(subtitle ?? ""))
    }
}



// MARK: - Tarjeta de Glucosa Actual
struct CurrentGlucoseCard: View {
    let reading: GlucoseReading?
    let trend: GlucoseTrend
    
    enum GlucoseTrend {
        case rising, stable, falling
        
        var icon: String {
            switch self {
            case .rising: return "arrow.up.circle.fill"
            case .stable: return "minus.circle.fill"
            case .falling: return "arrow.down.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .rising: return .orange
            case .stable: return .green
            case .falling: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Tu Glucosa Actual")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.title2)
                    .foregroundColor(trend.color)
            }
            
            if let reading = reading {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(Int(reading.value))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(glucoseColor(reading.value))
                    
                    Text("mg/dL")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Text(glucoseStatus(reading.value))
                    .font(.title3.weight(.semibold))
                    .foregroundColor(glucoseColor(reading.value))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(glucoseColor(reading.value).opacity(0.1))
                    .cornerRadius(20)
            } else {
                VStack(spacing: 15) {
                    Text("Sin Lectura Reciente")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    SeniorFriendlyButton(
                        title: "Agregar Lectura",
                        icon: "plus.circle",
                        backgroundColor: .blue,
                        size: .small
                    ) {
                        // Agregar nueva lectura
                    }
                }
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private func glucoseColor(_ value: Double) -> Color {
        switch value {
        case ..<80: return .red
        case 80..<140: return .green
        case 140..<180: return .orange
        default: return .red
        }
    }
    
    private func glucoseStatus(_ value: Double) -> String {
        switch value {
        case ..<80: return "Baja"
        case 80..<140: return "Normal"
        case 140..<180: return "Elevada"
        default: return "Muy Alta"
        }
    }
}

// MARK: - Barra de Progreso
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Paso \(currentStep + 1) de \(totalSteps)")
                    .font(DesignSystem.bodyFont)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)      // ✅ MÁS espacio arriba
        .padding(.bottom, 15)   // ✅ MÁS espacio abajo
    }
}


// MARK: - Botones de Navegación
struct NavigationButtons: View {
    let canGoBack: Bool
    let canGoForward: Bool
    let backTitle: String
    let forwardTitle: String
    let onBack: () -> Void
    let onForward: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Botón Atrás
            if canGoBack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(backTitle)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                // Spacer invisible para mantener el botón derecho en su lugar
                Spacer()
                    .frame(width: 80)
            }
            
            Spacer()
            
            // Botón Continuar/Finalizar
            Button(action: onForward) {
                HStack(spacing: 8) {
                    Text(forwardTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .frame(minWidth: 120)
                .background(canGoForward ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 20)
    }
}
// MARK: - Vista de Procesamiento
struct ProcessingView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        VStack(spacing: 30) {
            // Animación de procesamiento
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.blue, lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            }
            
            VStack(spacing: 15) {
                Text("Analizando tu Comida")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.primary)
                
                Text("Calculando el mejor orden con inteligencia artificial...")
                    .font(DesignSystem.bodyFont)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

// MARK: - Vista de Resultado de Optimización
struct OptimizationResultView: View {
    let prediction: GlucosePrediction
    
    var body: some View {
        VStack(spacing: 25) {
            // Resultado principal
            VStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("¡Orden Optimizado!")
                    .font(DesignSystem.hugeTitle)
                    .foregroundColor(.primary)
                
                Text("Pico estimado: \(Int(prediction.estimatedPeak)) mg/dL")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(prediction.estimatedPeak > 140 ? .orange : .green)
            }
            
            // Beneficio
            if prediction.glucoseReduction > 5 {
                BenefitCard(reduction: prediction.glucoseReduction)
            }
            
            // Preview del orden
            OrderPreview(foods: prediction.recommendedOrder)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
}

// MARK: - Tarjeta de Beneficio
struct BenefitCard: View {
    let reduction: Double
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.title)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Reducción Estimada")
                    .font(DesignSystem.smallFont)
                    .foregroundColor(.secondary)
                
                Text("-\(Int(reduction)) mg/dL")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.green)
                    .bold()
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Preview del Orden
struct OrderPreview: View {
    let foods: [Food]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Orden Recomendado:")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
            
            ForEach(Array(foods.prefix(3).enumerated()), id: \.offset) { index, food in
                HStack(spacing: 15) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        )
                    
                    Text(food.displayName)
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: food.category.icon)
                        .foregroundColor(food.category.color)
                }
            }
            
            if foods.count > 3 {
                Text("... y \(foods.count - 3) más")
                    .font(DesignSystem.smallFont)
                    .foregroundColor(.secondary)
                    .padding(.leading, 45)
            }
        }
    }
}

// MARK: - Header de Éxito
struct SuccessHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("¡Orden Calculado!")
                .font(DesignSystem.hugeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Aquí está tu secuencia personalizada")
                .font(DesignSystem.bodyFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Tarjeta de Resultado Principal
struct MainResultCard: View {
    let prediction: GlucosePrediction
    
    var body: some View {
        VStack(spacing: 20) {
            // Pico estimado
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Pico Estimado")
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(prediction.estimatedPeak)) mg/dL")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(prediction.estimatedPeak > 140 ? .orange : .green)
                }
                
                Spacer()
                
                // Indicador de confianza
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Confianza")
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 5) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(Double(index) < prediction.confidence * 5 ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
            
            // Beneficio si hay reducción significativa
            if prediction.glucoseReduction > 10 {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Reducción: \(Int(prediction.glucoseReduction)) mg/dL")
                        .font(DesignSystem.titleFont)
                        .foregroundColor(.green)
                        .bold()
                    
                    Spacer()
                }
                .padding(15)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Orden Paso a Paso
struct StepByStepOrder: View {
    let foods: [Food]
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tu Orden Paso a Paso:")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
            
            ForEach(Array(foods.enumerated()), id: \.offset) { index, food in
                HStack(spacing: 20) {
                    // Número del paso
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 40, height: 40)
                        
                        Text("\(index + 1)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    
                    // Información del alimento
                    VStack(alignment: .leading, spacing: 5) {
                        Text(food.displayName)
                            .font(DesignSystem.bodyFont.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text(getStepExplanation(for: food, step: index + 1))
                            .font(DesignSystem.captionFont)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    // Icono del tipo de alimento
                    Image(systemName: food.category.icon)
                        .font(.title2)
                        .foregroundColor(food.category.color)
                }
                .padding(.vertical, 10)
            }
            
            // Explicación general
            Text(explanation)
                .font(DesignSystem.bodyFont)
                .foregroundColor(.secondary)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(25)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(20)
    }
    
    private func getStepExplanation(for food: Food, step: Int) -> String {
        if food.fiberContent > 3.0 {
            return "Rica en fibra - ralentiza absorción de azúcares"
        } else if food.proteinContent > 10.0 {
            return "Alta proteína - estabiliza niveles de glucosa"
        } else if food.carbContent > 15.0 {
            return step == 1 ? "Intenta comer después de fibra/proteína" : "Al final para minimizar picos"
        } else {
            return "Complementa perfectamente tu comida balanceada"
        }
    }
}

// MARK: - Selección Manual de Alimentos
struct ManualFoodSelectionView: View {
    @Binding var selectedFoods: [Food]
    @StateObject private var foodDatabase = AdvancedFoodDatabase.shared
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategoryExtended = .all // ← Nueva categoría "Todo"
    
    // ✅ NUEVA: Enum extendido con categoría "Todo"
    enum FoodCategoryExtended: String, CaseIterable {
        case all = "Todo"
        case vegetables = "Vegetales"
        case proteins = "Proteínas"
        case carbohydrates = "Carbohidratos"
        case fruits = "Frutas"
        case fats = "Grasas"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .vegetables: return "leaf.fill"
            case .proteins: return "flame.fill"
            case .carbohydrates: return "bolt.fill"
            case .fruits: return "apple.logo"
            case .fats: return "circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .vegetables: return .green
            case .proteins: return .red
            case .carbohydrates: return .orange
            case .fruits: return .purple
            case .fats: return .yellow
            }
        }
        
        // Convertir a categoría original cuando no sea "Todo"
        var originalCategory: Food.FoodCategory? {
            switch self {
            case .all: return nil
            case .vegetables: return .vegetables
            case .proteins: return .proteins
            case .carbohydrates: return .carbohydrates
            case .fruits: return .fruits
            case .fats: return .fats
            }
        }
    }
    
    var filteredFoods: [Food] {
        let allFoods = foodDatabase.mexicanFoods.values
        
        // Filtrar por categoría
        let categoryFoods: [Food]
        if selectedCategory == .all {
            categoryFoods = Array(allFoods) // ✅ Mostrar TODOS los alimentos
        } else if let category = selectedCategory.originalCategory {
            categoryFoods = allFoods.filter { $0.category == category }
        } else {
            categoryFoods = Array(allFoods)
        }
        
        // Filtrar por búsqueda
        let searchFilteredFoods: [Food]
        if searchText.isEmpty {
            searchFilteredFoods = categoryFoods
        } else {
            searchFilteredFoods = categoryFoods.filter {
                $0.displayName.lowercased().contains(searchText.lowercased())
            }
        }
        
        return searchFilteredFoods.sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Buscador más compacto
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Buscar alimento...", text: $searchText)
                    .font(DesignSystem.bodyFont)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // ✅ MEJORA: Selector de categorías con "Todo"
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FoodCategoryExtended.allCases, id: \.self) { category in
                        CategoryButtonExtended(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            
            // ✅ MEJORA: Lista con más espacio y mejor scroll
            ScrollView {
                LazyVStack(spacing: 8) { // ← Spacing más compacto
                    ForEach(filteredFoods) { food in
                        CompactFoodRow( // ← Filas más compactas
                            food: food,
                            isSelected: selectedFoods.contains { $0.id == food.id }
                        ) { isSelected in
                            if isSelected {
                                selectedFoods.append(food)
                            } else {
                                selectedFoods.removeAll { $0.id == food.id }
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .frame(maxHeight: .infinity) // ← Usar todo el espacio disponible
        }
    }
}


// MARK: - Botón de Categoría
struct CategoryButton: View {
    let category: Food.FoodCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Fila de Alimento Manual
struct ManualFoodRow: View {
    let food: Food
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono de categoría
            Image(systemName: food.category.icon)
                .font(.title2)
                .foregroundColor(food.category.color)
                .frame(width: 30)
            
            // Información del alimento
            VStack(alignment: .leading, spacing: 4) {
                Text(food.displayName)
                    .font(DesignSystem.bodyFont)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    if food.fiberContent > 0 {
                        NutrientLabel(icon: "leaf.fill", value: "\(String(format: "%.1f", food.fiberContent))g", color: .green)
                    }
                    if food.proteinContent > 0 {
                        NutrientLabel(icon: "flame.fill", value: "\(String(format: "%.1f", food.proteinContent))g", color: .red)
                    }
                    if food.carbContent > 0 {
                        NutrientLabel(icon: "bolt.fill", value: "\(String(format: "%.1f", food.carbContent))g", color: .orange)
                    }
                }
            }
            
            Spacer()
            
            // Checkbox
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Etiqueta de Nutriente
struct NutrientLabel: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Fila de Confirmación de Alimento
struct FoodConfirmationRow: View {
    let food: Food
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Checkbox
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            // Información del alimento
            VStack(alignment: .leading, spacing: 5) {
                Text(food.displayName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 15) {
                    Label("\(Int(food.fiberContent))g fibra", systemImage: "leaf.fill")
                    Label("\(Int(food.proteinContent))g proteína", systemImage: "flame.fill")
                    Label("\(Int(food.carbContent))g carbos", systemImage: "bolt.fill")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Botón editar
            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Vista de Cámara Mejorada con ML
struct CameraView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var foodRecognizer: EnhancedFoodRecognizer
    let onCapture: (UIImage) -> Void
    
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Área principal de imagen/cámara
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 320)
                    .cornerRadius(15)
                
                // Mostrar imagen capturada o placeholder
                if let image = foodRecognizer.processedImage ?? capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 320)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 3)
                        )
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            Text("🤖 Cámara con IA")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text("Detecta automáticamente tus alimentos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // Overlay de procesamiento
                if foodRecognizer.isProcessing {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .cornerRadius(15)
                        
                        VStack(spacing: 20) {
                            // Animación de procesamiento más atractiva
                            ZStack {
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: 0.3)
                                    .stroke(Color.blue, lineWidth: 6)
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(rotation))
                                    .onAppear {
                                        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                                            rotation = 360
                                        }
                                    }
                            }
                            
                            VStack(spacing: 8) {
                                Text("🧠 Analizando con IA...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Identificando alimentos automáticamente")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
            }
            
            // Panel de resultados de detección
            if !foodRecognizer.detectedFoods.isEmpty {
                MLDetectionResultsPanel(
                    detectedFoods: foodRecognizer.detectedFoods,
                    confidence: foodRecognizer.confidence
                )
                .padding(.top, 15)
            }
            
            // Botones de control
            HStack(spacing: 25) {
                // Botón galería
                Button(action: {
                    showingActionSheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Galería")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Botón principal de captura
                Button(action: {
                    showingImagePicker = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                        
                        Circle()
                            .stroke(Color.blue, lineWidth: 4)
                            .frame(width: 65, height: 65)
                        
                        if foodRecognizer.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .disabled(foodRecognizer.isProcessing)
                
                Spacer()
                
                // Botón reset/nueva foto
                Button(action: {
                    resetCamera()
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Nuevo")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerController { image in
                processImage(image)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Seleccionar imagen"),
                buttons: [
                    .default(Text("📸 Cámara")) {
                        showingImagePicker = true
                    },
                    .default(Text("🖼️ Galería de fotos")) {
                        // Aquí podrías implementar selección de galería
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
    }
    
    @State private var rotation = 0.0
    
    private func processImage(_ image: UIImage) {
        capturedImage = image
        
        // Usar el EnhancedFoodRecognizer con ML
        foodRecognizer.recognizeFoods(in: image) { detectedFoods in
            // Callback al completar
            onCapture(image)
        }
    }
    
    private func resetCamera() {
        capturedImage = nil
        foodRecognizer.reset()
    }
}

// MARK: - Panel de Resultados de ML
struct MLDetectionResultsPanel: View {
    let detectedFoods: [EnhancedFoodRecognizer.DetectedFood]
    let confidence: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Header con estadísticas
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("IA detectó \(detectedFoods.count) alimentos")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Confianza general: \(Int(confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Indicador de confianza por colores
                ConfidenceIndicator(confidence: confidence)
            }
            
            // Lista de alimentos detectados
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(detectedFoods) { detection in
                        DetectedFoodCard(detection: detection)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Tarjeta de alimento detectado mejorada
struct DetectedFoodCard: View {
    let detection: EnhancedFoodRecognizer.DetectedFood
    
    var body: some View {
        VStack(spacing: 10) {
            // Icono con color de categoría
            ZStack {
                Circle()
                    .fill(detection.food.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: detection.food.category.icon)
                    .font(.title2)
                    .foregroundColor(detection.food.category.color)
            }
            
            // Información del alimento
            VStack(spacing: 4) {
                Text(detection.food.displayName)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
                
                // Badge de confianza
                Text("\(Int(detection.confidence * 100))%")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(confidenceColor(detection.confidence))
                    .cornerRadius(10)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: detection.food.category.color.opacity(0.3), radius: 3, x: 0, y: 2)
    }
    
    private func confidenceColor(_ confidence: Float) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        case 0.4..<0.6: return .yellow
        default: return .red
        }
    }
}

// MARK: - Indicador de Confianza
struct ConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(Double(index) < confidence * 5 ? .yellow : .gray.opacity(0.3))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// MARK: - Image Picker Controller
struct ImagePickerController: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageSelected: (UIImage) -> Void
        
        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
// MARK: - Selector de Método de Captura
struct CaptureMethodSelector: View {
    @Binding var selectedMethod: MealCaptureManager.CaptureMethod
    
    var body: some View {
        VStack(spacing: 20) {  // ✅ MÁS espaciado
            Text("¿Cómo prefieres capturar?")
                .font(DesignSystem.bodyFont)
                .foregroundColor(.secondary)
                .padding(.top, 10)  // ✅ Espacio extra arriba
            
            HStack(spacing: 15) {
                MethodButton(
                    title: "Cámara",
                    icon: "camera.fill",
                    isSelected: selectedMethod == .camera
                ) {
                    selectedMethod = .camera
                }
                
                MethodButton(
                    title: "Manual",
                    icon: "list.bullet",
                    isSelected: selectedMethod == .manual
                ) {
                    selectedMethod = .manual
                }
            }
        }
        .padding(.bottom, 15)  // ✅ Espacio abajo del selector
    }
}


// MARK: - Botón de Método
struct MethodButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .blue)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)  // ✅ Altura fija más pequeña
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 2)
            )
        }
    }
}

        // MARK: - Componentes del Dashboard
        struct GreetingCard: View {
            var body: some View {
                let hour = Calendar.current.component(.hour, from: Date())
                let greeting = hour < 12 ? "Buenos días" : hour < 18 ? "Buenas tardes" : "Buenas noches"
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting)
                            .font(DesignSystem.titleFont)
                            .foregroundColor(.primary)
                        
                        Text("¿Cómo podemos ayudarte hoy?")
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "sun.max.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

// MARK: - QuickActionsGrid Corregido
// MARK: - QuickActionsGrid Corregido (Solo el componente que necesitas)
// MARK: - QuickActionsGrid Actualizado
// MARK: - QuickActionsGrid Actualizado
struct QuickActionsGrid: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @ObservedObject var speechManager: SpeechManager
    @State private var showingGlucoseAlert = false
    @State private var glucoseInput = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Acciones Rápidas")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                // Botón 1: Agregar Glucosa
                Button(action: {
                    showingGlucoseAlert = true
                    glucoseInput = ""
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "drop.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 2) {
                            Text("Agregar")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Glucosa")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                
                // Botón 2: Repetir Instrucciones (ACTUALIZADO)
                Button(action: {
                    speechManager.repeatLastInstructions()
                }) {
                    VStack(spacing: 10) {
                        // NUEVO: Icono dinámico según si hay instrucciones
                        Image(systemName: speechManager.hasLastInstructions ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 2) {
                            Text("Repetir")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(speechManager.hasLastInstructions ? "Instrucciones" : "Sin Datos")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .background(speechManager.hasLastInstructions ? Color.purple : Color.gray)
                    .cornerRadius(15)
                    .shadow(color: (speechManager.hasLastInstructions ? Color.purple : Color.gray).opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(!speechManager.hasLastInstructions && !speechManager.isSpeaking)
            }
            
            // NUEVO: Indicador de estado
            if speechManager.hasLastInstructions {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("Última comida: \(speechManager.lastOptimalOrder?.first?.displayName ?? "N/A") y \(max(0, (speechManager.lastOptimalOrder?.count ?? 1) - 1)) más")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
            } else {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("Analiza una comida primero para poder repetir instrucciones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
        }
        .alert("Agregar Lectura de Glucosa", isPresented: $showingGlucoseAlert) {
            TextField("Ej: 120", text: $glucoseInput)
                .keyboardType(.numberPad)
            
            Button("Guardar") {
                saveGlucoseReading()
            }
            .disabled(glucoseInput.isEmpty)
            
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Ingresa tu lectura actual en mg/dL")
        }
    }
    
    private func saveGlucoseReading() {
        guard let value = Double(glucoseInput), value > 40, value < 600 else { return }
        
        let newReading = GlucoseReading(
            value: value,
            timestamp: Date(),
            context: "Manual",
            mealId: nil
        )
        
        // Agregar a glucoseManager
        glucoseManager.recentReadings.insert(newReading, at: 0)
        glucoseManager.allReadings.insert(newReading, at: 0)
        glucoseManager.currentReading = newReading
        
        // Mantener solo las últimas 50 lecturas
        if glucoseManager.recentReadings.count > 50 {
            glucoseManager.recentReadings = Array(glucoseManager.recentReadings.prefix(50))
        }
        
        // También guardar en SimpleDataManager
        SimpleDataManager.shared.addGlucoseReading(newReading)
        
        // Feedback de voz
        speechManager.speak("Lectura de \(Int(value)) miligramos por decilitro guardada correctamente.")
        
        glucoseInput = ""
    }
}
// MARK: - Extensión para agregar función speak directa a SpeechManager
extension SpeechManager {
    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Detener cualquier locución anterior
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        isSpeaking = true
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") ?? AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.45
        utterance.volume = 0.9
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
        
        let estimatedDuration = Double(text.count) * 0.08
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration + 1.0) {
            self.isSpeaking = false
        }
    }
}
// MARK: - Alternativa con SeniorFriendlyButton Compacto
struct CompactSeniorButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - QuickActionsGrid usando CompactSeniorButton
struct QuickActionsGridAlternative: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @ObservedObject var speechManager: SpeechManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Acciones Rápidas")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                CompactSeniorButton(
                    title: "Agregar",
                    subtitle: "Glucosa",
                    icon: "drop.circle.fill",
                    backgroundColor: .green
                ) {
                    // Agregar nueva lectura de glucosa
                }
                
                CompactSeniorButton(
                    title: "Repetir",
                    subtitle: "Últimas",
                    icon: "speaker.wave.2.fill",
                    backgroundColor: .purple
                ) {
                    speechManager.repeatLastInstructions()
                }
            }
        }
    }
}

// MARK: - Versión con Grid 2x2 para más acciones
// MARK: - Acciones Rápidas Mejoradas con Funcionalidad Completa
struct ImprovedQuickActionsGrid: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @ObservedObject var speechManager: SpeechManager
    @State private var showingGlucoseInput = false
    @State private var showingEmergencyCall = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Acciones Rápidas")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                // 1. Agregar Lectura de Glucosa
                CompactActionButton(
                    title: "Medir",
                    subtitle: "Glucosa",
                    icon: "drop.circle.fill",
                    backgroundColor: .green,
                    description: "Registra tu nivel actual de glucosa"
                ) {
                    showingGlucoseInput = true
                }
                
                // 2. Repetir Instrucciones por Voz
                CompactActionButton(
                    title: "Escuchar",
                    subtitle: "Instrucciones",
                    icon: "speaker.wave.2.fill",
                    backgroundColor: .purple,
                    description: "Repetir orden de comida recomendado"
                ) {
                    speechManager.repeatLastInstructions()
                }
            }
            
            HStack(spacing: 15) {
                // 3. Nueva Comida Rápida
                CompactActionButton(
                    title: "Nueva",
                    subtitle: "Comida",
                    icon: "camera.viewfinder",
                    backgroundColor: .blue,
                    description: "Analizar nueva comida rápidamente"
                ) {
                    // Navegar a nueva comida
                }
                
                // 4. Llamada de Emergencia (para adultos mayores)
                CompactActionButton(
                    title: "Ayuda",
                    subtitle: "Médica",
                    icon: "phone.fill",
                    backgroundColor: .red,
                    description: "Contactar emergencia médica"
                ) {
                    showingEmergencyCall = true
                }
            }
        }
        .sheet(isPresented: $showingGlucoseInput) {
            QuickGlucoseInputView(glucoseManager: glucoseManager)
        }
        .alert("Llamada de Emergencia", isPresented: $showingEmergencyCall) {
            Button("Llamar 911", role: .destructive) {
                makeEmergencyCall()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Necesitas ayuda médica inmediata?")
        }
    }
    
    private func makeEmergencyCall() {
        // En México: 911 para emergencias
        if let url = URL(string: "tel://911") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Botón de Acción Compacto con Descripción
struct CompactActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: Color
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .accessibility(label: Text("\(title) \(subtitle)"))
        .accessibility(hint: Text(description))
    }
}

// MARK: - Vista Rápida para Entrada de Glucosa
struct QuickGlucoseInputView: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var glucoseValue = ""
    @State private var selectedContext = "Manual"
    @State private var showingSuccess = false
    
    let contexts = ["Ayuno", "Pre-comida", "Post-comida", "Manual", "Síntoma"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "drop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Registrar Glucosa")
                        .font(DesignSystem.hugeTitle)
                        .foregroundColor(.primary)
                    
                    Text("Ingresa tu lectura actual")
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                }
                
                // Input de glucosa
                VStack(spacing: 20) {
                    HStack {
                        TextField("100", text: $glucoseValue)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("mg/dL")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 40)
                    
                    // Selector de contexto
                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Cuándo midiste?")
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                        
                        Picker("Contexto", selection: $selectedContext) {
                            ForEach(contexts, id: \.self) { context in
                                Text(context).tag(context)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Estado de la glucosa
                if let value = Double(glucoseValue), value > 0 {
                    GlucoseStatusIndicator(value: value)
                }
                
                Spacer()
                
                // Botones de acción
                VStack(spacing: 15) {
                    SeniorFriendlyButton(
                        title: "Guardar Lectura",
                        icon: "checkmark.circle.fill",
                        backgroundColor: canSave ? .green : .gray,
                        size: .large
                    ) {
                        saveGlucoseReading()
                    }
                    .disabled(!canSave)
                    
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(DesignSystem.bodyFont)
                    .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .background(DesignSystem.backgroundCream)
            .navigationTitle("Nueva Lectura")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("¡Lectura Guardada!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu lectura de \(glucoseValue) mg/dL ha sido registrada")
        }
    }
    
    private var canSave: Bool {
        guard let value = Double(glucoseValue) else { return false }
        return value > 40 && value < 600 // Rango realista
    }
    
    private func saveGlucoseReading() {
        guard let value = Double(glucoseValue) else { return }
        
        let newReading = GlucoseReading(
            value: value,
            timestamp: Date(),
            context: selectedContext,
            mealId: nil
        )
        
        glucoseManager.addGlucoseReading(newReading)
        showingSuccess = true
    }
}

// MARK: - Indicador de Estado de Glucosa
struct GlucoseStatusIndicator: View {
    let value: Double
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(statusColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(statusColor)
                
                Text(recommendationText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(15)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch value {
        case ..<70: return .red
        case 70..<80: return .orange
        case 80..<140: return .green
        case 140..<180: return .orange
        default: return .red
        }
    }
    
    private var statusText: String {
        switch value {
        case ..<70: return "Hipoglucemia"
        case 70..<80: return "Baja"
        case 80..<140: return "Normal"
        case 140..<180: return "Elevada"
        default: return "Muy Alta"
        }
    }
    
    private var recommendationText: String {
        switch value {
        case ..<70: return "Consume algo dulce inmediatamente"
        case 70..<80: return "Considera un snack saludable"
        case 80..<140: return "¡Excelente control!"
        case 140..<180: return "Evita carbohidratos por ahora"
        default: return "Consulta a tu médico"
        }
    }
}

// MARK: - Extensión para GlucoseManager
extension GlucoseManager {
    /*func addGlucoseReading(_ reading: GlucoseReading) {
        // ✅ CLAVE: Limpiar datos de muestra al agregar primera lectura real
        if isFirstRealReading {
            recentReadings.removeAll()  // Eliminar datos de muestra
            allReadings.removeAll()
            isFirstRealReading = false  // Marcar que ya no es la primera
            print("🧹 Datos de muestra eliminados - ahora solo datos reales")
        }
        
        recentReadings.insert(reading, at: 0)
        allReadings.insert(reading, at: 0)
        currentReading = reading
        
        if recentReadings.count > 50 {
            recentReadings = Array(recentReadings.prefix(50))
        }
        
        SimpleDataManager.shared.addGlucoseReading(reading)
    }
*/
}
        struct TodayRecommendationCard: View {
            let recommendation: DailyRecommendation
            
            var body: some View {
                HStack(spacing: 15) {
                    Image(systemName: recommendation.icon)
                        .font(.title)
                        .foregroundColor(recommendation.color)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recommendation.title)
                            .font(DesignSystem.titleFont)
                            .foregroundColor(.primary)
                        
                        Text(recommendation.message)
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(recommendation.color.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(recommendation.color.opacity(0.3), lineWidth: 1)
                )
            }
        }

        struct RecentSummaryCard: View {
            let readings: [GlucoseReading]
            
            var body: some View {
                VStack(spacing: 15) {
                    HStack {
                        Text("Resumen Reciente")
                            .font(DesignSystem.titleFont)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    if readings.isEmpty {
                        Text("No hay lecturas recientes")
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(readings.prefix(3)) { reading in
                                HStack {
                                    Text(reading.context ?? "Lectura")
                                        .font(DesignSystem.bodyFont)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(reading.value)) mg/dL")
                                        .font(DesignSystem.bodyFont.weight(.semibold))
                                        .foregroundColor(glucoseColor(reading.value))
                                    
                                    Text(timeAgo(reading.timestamp))
                                        .font(DesignSystem.captionFont)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
            private func glucoseColor(_ value: Double) -> Color {
                switch value {
                case ..<80: return .red
                case 80..<140: return .green
                case 140..<180: return .orange
                default: return .red
                }
            }
            
            private func timeAgo(_ date: Date) -> String {
                let interval = Date().timeIntervalSince(date)
                let hours = Int(interval / 3600)
                let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
                
                if hours > 0 {
                    return "\(hours)h"
                } else if minutes > 0 {
                    return "\(minutes)m"
                } else {
                    return "Ahora"
                }
            }
        }

        // MARK: - Componentes Adicionales
// MARK: - LastReadingCard Mejorado
struct LastReadingCard: View {
    let reading: GlucoseReading
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: { onToggle(!isSelected) }) {
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Usar última lectura")
                            .font(DesignSystem.bodyFont.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text("Medida \(timeAgo(reading.timestamp))")
                            .font(DesignSystem.captionFont)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Mostrar el valor de glucosa de forma prominente
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(Int(reading.value))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(glucoseColor(reading.value))
                            
                            Text("mg/dL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Indicador de estado
                        Text(glucoseStatus(reading.value))
                            .font(.caption2.weight(.medium))
                            .foregroundColor(glucoseColor(reading.value))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(glucoseColor(reading.value).opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Información adicional si está seleccionado
                if isSelected {
                    VStack(spacing: 8) {
                        Divider()
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("Se usará esta lectura para calcular tu predicción personalizada")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func glucoseColor(_ value: Double) -> Color {
        switch value {
        case ..<70: return .red
        case 70..<80: return .orange
        case 80..<140: return .green
        case 140..<180: return .orange
        default: return .red
        }
    }
    
    private func glucoseStatus(_ value: Double) -> String {
        switch value {
        case ..<70: return "Baja"
        case 70..<80: return "Límite"
        case 80..<140: return "Normal"
        case 140..<180: return "Elevada"
        default: return "Alta"
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        
        if hours > 0 {
            return "hace \(hours)h"
        } else if minutes > 0 {
            return "hace \(minutes)m"
        } else {
            return "ahora"
        }
    }
}

        // MARK: - Componentes del Historial
        struct GlucoseChart: View {
            let readings: [GlucoseReading]
            let timeRange: HistoryView.TimeRange
            
            var body: some View {
                VStack(spacing: 15) {
                    Text("Tendencia de Glucosa")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Gráfica simplificada
                    if readings.isEmpty {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("No hay datos para mostrar")
                                    .foregroundColor(.secondary)
                            )
                            .cornerRadius(10)
                    } else {
                        SimpleLineChart(readings: readings)
                            .frame(height: 200)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

        struct SimpleLineChart: View {
            let readings: [GlucoseReading]
            
            var body: some View {
                GeometryReader { geometry in
                    Path { path in
                        guard !readings.isEmpty else { return }
                        
                        let sortedReadings = readings.sorted { $0.timestamp < $1.timestamp }
                        let maxValue = sortedReadings.map { $0.value }.max() ?? 200
                        let minValue = sortedReadings.map { $0.value }.min() ?? 80
                        let valueRange = maxValue - minValue
                        
                        for (index, reading) in sortedReadings.enumerated() {
                            let x = geometry.size.width * CGFloat(index) / CGFloat(sortedReadings.count - 1)
                            let y = geometry.size.height * (1 - CGFloat((reading.value - minValue) / valueRange))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 3)
                }
                .background(
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                )
            }
        }

        struct StatsSummaryCard: View {
            let readings: [GlucoseReading]
            
            var body: some View {
                VStack(spacing: 15) {
                    Text("Estadísticas")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        StatItem(
                            title: "Promedio",
                            value: "\(Int(averageGlucose)) mg/dL",
                            color: .blue
                        )
                        
                        Spacer()
                        
                        StatItem(
                            title: "Rango",
                            value: "Normal",
                            color: rangeColor
                        )
                        
                        Spacer()
                        
                        StatItem(
                            title: "Lecturas",
                            value: "\(readings.count)",
                            color: .purple
                        )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
            private var averageGlucose: Double {
                guard !readings.isEmpty else { return 0 }
                return readings.reduce(0) { $0 + $1.value } / Double(readings.count)
            }
            
            private var rangeColor: Color {
                let avg = averageGlucose
                if avg < 80 || avg > 180 { return .red }
                if avg > 140 { return .orange }
                return .green
            }
        }

        struct StatItem: View {
            let title: String
            let value: String
            let color: Color
            
            var body: some View {
                VStack(spacing: 5) {
                    Text(value)
                        .font(.title2.bold())
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }

        struct RecentMealsSection: View {
            let meals: [SavedMeal]
            
            var body: some View {
                VStack(spacing: 15) {
                    Text("Comidas Recientes")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if meals.isEmpty {
                        Text("No hay comidas registradas")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(meals.prefix(3)) { meal in
                            MealSummaryRow(meal: meal)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

        struct MealSummaryRow: View {
            let meal: SavedMeal
            
            var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meal.foods.map { $0.displayName }.joined(separator: ", "))
                            .font(.body)
                            .lineLimit(2)
                        
                        Text(timeAgo(meal.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("\(Int(meal.predictedPeak)) mg/dL")
                            .font(.body.bold())
                            .foregroundColor(meal.predictedPeak > 140 ? .orange : .green)
                        
                        if meal.followedRecommendation {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            
            private func timeAgo(_ date: Date) -> String {
                let interval = Date().timeIntervalSince(date)
                let days = Int(interval / 86400)
                let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
                
                if days > 0 {
                    return "hace \(days)d"
                } else if hours > 0 {
                    return "hace \(hours)h"
                } else {
                    return "hoy"
                }
            }
        }

        struct PatternsSection: View {
            let readings: [GlucoseReading]
            
            var body: some View {
                VStack(spacing: 15) {
                    Text("Patrones Detectados")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 10) {
                        PatternCard(
                            icon: "clock.fill",
                            title: "Mejor Horario",
                            description: "Tus niveles son más estables en las mañanas",
                            color: .blue
                        )
                        
                        PatternCard(
                            icon: "arrow.down.circle.fill",
                            title: "Progreso",
                            description: "Promedio ha mejorado 8% esta semana",
                            color: .green
                        )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

        struct PatternCard: View {
            let icon: String
            let title: String
            let description: String
            let color: Color
            
            var body: some View {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.body.bold())
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(15)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            }
        }

        // MARK: - Componentes del Perfil
        struct UserInfoCard: View {
            let profile: UserProfile
            let onEdit: () -> Void
            
            var body: some View {
                VStack(spacing: 20) {
                    // Avatar y nombre
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Mi Perfil")
                            .font(DesignSystem.titleFont)
                            .foregroundColor(.primary)
                    }
                    
                    // Información básica
                    VStack(spacing: 15) {
                        ProfileInfoRow(label: "Edad", value: "\(profile.age) años")
                        ProfileInfoRow(label: "Peso", value: "\(Int(profile.weight)) kg")
                        ProfileInfoRow(label: "Altura", value: "\(Int(profile.height)) cm")
                        ProfileInfoRow(label: "IMC", value: String(format: "%.1f", profile.bmi))
                        ProfileInfoRow(label: "Tipo", value: profile.diabetesType.rawValue)
                    }
                    
                    // Botón editar
                    SeniorFriendlyButton(
                        title: "Editar Perfil",
                        icon: "pencil.circle",
                        backgroundColor: .blue,
                        size: .medium
                    ) {
                        onEdit()
                    }
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
            }
        }

        struct ProfileInfoRow: View {
            let label: String
            let value: String
            
            var body: some View {
                HStack {
                    Text(label)
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(value)
                        .font(DesignSystem.bodyFont.weight(.semibold))
                        .foregroundColor(.primary)
                }
            }
        }

        struct PersonalStatsCard: View {
            let profile: UserProfile
            let recentReadings: [GlucoseReading]
            
            var body: some View {
                VStack(spacing: 15) {
                    Text("Mis Estadísticas")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        PersonalStatRow(
                            icon: "target",
                            label: "Glucosa Objetivo",
                            value: "80-140 mg/dL",
                            color: .green
                        )
                        
                        PersonalStatRow(
                            icon: "chart.line.uptrend.xyaxis",
                            label: "Promedio 7 días",
                            value: "\(averageLastWeek) mg/dL",
                            color: averageColor
                        )
                        
                        PersonalStatRow(
                            icon: "checkmark.circle",
                            label: "En rango",
                            value: "\(inRangePercentage)%",
                            color: .blue
                        )
                        
                        PersonalStatRow(
                            icon: "flame",
                            label: "Sensibilidad",
                            value: sensitivityText,
                            color: .orange
                        )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
            private var averageLastWeek: Int {
                guard !recentReadings.isEmpty else { return 0 }
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                let weekReadings = recentReadings.filter { $0.timestamp >= weekAgo }
                guard !weekReadings.isEmpty else { return 0 }
                return Int(weekReadings.reduce(0) { $0 + $1.value } / Double(weekReadings.count))
            }
            
            private var averageColor: Color {
                let avg = Double(averageLastWeek)
                if avg < 80 || avg > 180 { return .red }
                if avg > 140 { return .orange }
                return .green
            }
            
            private var inRangePercentage: Int {
                guard !recentReadings.isEmpty else { return 0 }
                let inRange = recentReadings.filter { $0.value >= 80 && $0.value <= 140 }.count
                return Int(Double(inRange) / Double(recentReadings.count) * 100)
            }
            
            private var sensitivityText: String {
                if profile.carbSensitivity > 1.2 {
                    return "Alta"
                } else if profile.carbSensitivity > 0.8 {
                    return "Normal"
                } else {
                    return "Baja"
                }
            }
        }

        struct PersonalStatRow: View {
            let icon: String
            let label: String
            let value: String
            let color: Color
            
            var body: some View {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                        .frame(width: 25)
                    
                    Text(label)
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(value)
                        .font(DesignSystem.bodyFont.weight(.semibold))
                        .foregroundColor(color)
                }
            }
        }

        struct SettingsSection: View {
            var body: some View {
                VStack(spacing: 15) {
                    Text("Configuración")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 10) {
                        SettingsRow(
                            icon: "speaker.wave.3",
                            title: "Instrucciones de Voz",
                            subtitle: "Activar guías habladas",
                            hasToggle: true
                        )
                        
                        SettingsRow(
                            icon: "bell",
                            title: "Recordatorios",
                            subtitle: "Configurar notificaciones",
                            hasToggle: false
                        )
                        
                        SettingsRow(
                            icon: "textformat.size",
                            title: "Tamaño de Texto",
                            subtitle: "Ajustar para mejor lectura",
                            hasToggle: false
                        )
                        
                        SettingsRow(
                            icon: "heart.text.square",
                            title: "Integración HealthKit",
                            subtitle: "Sincronizar datos de salud",
                            hasToggle: true
                        )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

        struct SettingsRow: View {
            let icon: String
            let title: String
            let subtitle: String
            let hasToggle: Bool
            @State private var isEnabled = true
            
            var body: some View {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(DesignSystem.captionFont)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if hasToggle {
                        Toggle("", isOn: $isEnabled)
                            .labelsHidden()
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }

        struct HelpSection: View {
            var body: some View {
                VStack(spacing: 15) {
                    Text("Ayuda y Soporte")
                        .font(DesignSystem.titleFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 10) {
                        HelpRow(
                            icon: "questionmark.circle",
                            title: "Preguntas Frecuentes",
                            subtitle: "Respuestas a dudas comunes"
                        )
                        
                        HelpRow(
                            icon: "book.circle",
                            title: "Guía de Uso",
                            subtitle: "Aprende a usar la app"
                        )
                        
                        HelpRow(
                            icon: "phone.circle",
                            title: "Contactar Soporte",
                            subtitle: "Obtén ayuda personalizada"
                        )
                        
                        HelpRow(
                            icon: "info.circle",
                            title: "Acerca de GluOrder",
                            subtitle: "Versión 1.0 - Información legal"
                        )
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

        struct HelpRow: View {
            let icon: String
            let title: String
            let subtitle: String
            
            var body: some View {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.green)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(DesignSystem.captionFont)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }

        struct EditProfileView: View {
            @Binding var profile: UserProfile
            @Environment(\.dismiss) private var dismiss
            
            @State private var tempAge: String
            @State private var tempWeight: String
            @State private var tempHeight: String
            @State private var tempDiabetesType: UserProfile.DiabetesType
            @State private var tempMedicationStatus: Bool
            
            init(profile: Binding<UserProfile>) {
                self._profile = profile
                self._tempAge = State(initialValue: "\(profile.wrappedValue.age)")
                self._tempWeight = State(initialValue: "\(Int(profile.wrappedValue.weight))")
                self._tempHeight = State(initialValue: "\(Int(profile.wrappedValue.height))")
                self._tempDiabetesType = State(initialValue: profile.wrappedValue.diabetesType)
                self._tempMedicationStatus = State(initialValue: profile.wrappedValue.medicationStatus)
            }
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Información personal
                            VStack(spacing: 20) {
                                Text("Información Personal")
                                    .font(DesignSystem.titleFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 15) {
                                    ProfileEditField(
                                        label: "Edad",
                                        value: $tempAge,
                                        placeholder: "65",
                                        keyboardType: .numberPad,
                                        suffix: "años"
                                    )
                                    
                                    ProfileEditField(
                                        label: "Peso",
                                        value: $tempWeight,
                                        placeholder: "70",
                                        keyboardType: .numberPad,
                                        suffix: "kg"
                                    )
                                    
                                    ProfileEditField(
                                        label: "Altura",
                                        value: $tempHeight,
                                        placeholder: "165",
                                        keyboardType: .numberPad,
                                        suffix: "cm"
                                    )
                                }
                            }
                            
                            // Información médica
                            VStack(spacing: 20) {
                                Text("Información Médica")
                                    .font(DesignSystem.titleFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 15) {
                                    // Tipo de diabetes
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Tipo de Diabetes")
                                            .font(DesignSystem.bodyFont)
                                            .foregroundColor(.secondary)
                                        
                                        Picker("Tipo de Diabetes", selection: $tempDiabetesType) {
                                            ForEach(UserProfile.DiabetesType.allCases, id: \.self) { type in
                                                Text(type.rawValue).tag(type)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                    
                                    // Medicación
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("¿Tomas medicamento para diabetes?")
                                                .font(DesignSystem.bodyFont)
                                                .foregroundColor(.secondary)
                                            
                                            Text("Esto ayuda a personalizar las predicciones")
                                                .font(DesignSystem.captionFont)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $tempMedicationStatus)
                                            .labelsHidden()
                                    }
                                }
                            }
                            
                            // Botón guardar
                            SeniorFriendlyButton(
                                title: "Guardar Cambios",
                                icon: "checkmark.circle.fill",
                                backgroundColor: .blue,
                                size: .large
                            ) {
                                saveProfile()
                            }
                        }
                        .padding(20)
                    }
                    .background(DesignSystem.backgroundCream)
                    .navigationTitle("Editar Perfil")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        leading: Button("Cancelar") { dismiss() }
                    )
                }
            }
            
            private func saveProfile() {
                // Validar y guardar datos
                if let age = Int(tempAge), age > 0 && age < 120,
                   let weight = Double(tempWeight), weight > 0 && weight < 300,
                   let height = Double(tempHeight), height > 0 && height < 250 {
                    
                    profile.age = age
                    profile.weight = weight
                    profile.height = height
                    profile.diabetesType = tempDiabetesType
                    profile.medicationStatus = tempMedicationStatus
                    
                    // Actualizar sensibilidad basada en perfil
                    updateSensitivityBasedOnProfile()
                    
                    dismiss()
                }
            }
            
            private func updateSensitivityBasedOnProfile() {
                // Ajustar sensibilidad según edad, tipo de diabetes, etc.
                var sensitivity = 1.0
                
                // Edad afecta sensibilidad
                if profile.age > 65 {
                    sensitivity *= 1.1
                }
                
                // Tipo de diabetes
                switch profile.diabetesType {
                case .type1:
                    sensitivity *= 1.3
                case .type2:
                    sensitivity *= 1.1
                case .prediabetes:
                    sensitivity *= 0.9
                case .none:
                    sensitivity *= 0.8
                }
                
                // Medicación reduce sensibilidad
                if profile.medicationStatus {
                    sensitivity *= 0.85
                }
                
                profile.carbSensitivity = sensitivity
            }
        }

        struct ProfileEditField: View {
            let label: String
            @Binding var value: String
            let placeholder: String
            let keyboardType: UIKeyboardType
            let suffix: String
            
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text(label)
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField(placeholder, text: $value)
                            .font(DesignSystem.bodyFont)
                            .keyboardType(keyboardType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(suffix)
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }

        struct FoodEditView: View {
            let food: Food
            let onSave: (Food) -> Void
            @Environment(\.dismiss) private var dismiss
            
            @State private var editedFood: Food
            @State private var portionText: String
            
            init(food: Food, onSave: @escaping (Food) -> Void) {
                self.food = food
                self.onSave = onSave
                self._editedFood = State(initialValue: food)
                self._portionText = State(initialValue: String(format: "%.1f", food.portion))
            }
            
            var body: some View {
                NavigationView {
                    VStack(spacing: 25) {
                        // Información del alimento
                        VStack(spacing: 15) {
                            Image(systemName: food.category.icon)
                                .font(.system(size: 60))
                                .foregroundColor(food.category.color)
                            
                            Text(food.displayName)
                                .font(DesignSystem.titleFont)
                                .foregroundColor(.primary)
                            
                            Text(food.category.rawValue)
                                .font(DesignSystem.bodyFont)
                                .foregroundColor(.secondary)
                        }
                        
                        // Ajuste de porción
                        VStack(spacing: 20) {
                            Text("Ajustar Porción")
                                .font(DesignSystem.titleFont)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("Porción:")
                                    .font(DesignSystem.bodyFont)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack {
                                    Button(action: { adjustPortion(-0.5) }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    TextField("1.0", text: $portionText)
                                        .font(DesignSystem.bodyFont)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: { adjustPortion(0.5) }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text("porciones")
                                    .font(DesignSystem.bodyFont)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Botones de acción
                        VStack(spacing: 15) {
                            SeniorFriendlyButton(
                                title: "Guardar Cambios",
                                icon: "checkmark.circle.fill",
                                backgroundColor: .blue,
                                size: .large
                            ) {
                                saveChanges()
                            }
                            
                            Button("Cancelar") {
                                dismiss()
                            }
                            .font(DesignSystem.bodyFont)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                    .background(DesignSystem.backgroundCream)
                    .navigationTitle("Editar Alimento")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .onChange(of: portionText) { value in
                    if let portion = Double(value), portion > 0 {
                        editedFood.portion = portion
                    }
                }
            }
            
            private func adjustPortion(_ change: Double) {
                let currentPortion = Double(portionText) ?? 1.0
                let newPortion = max(0.5, currentPortion + change)
                portionText = String(format: "%.1f", newPortion)
            }
            
            private func saveChanges() {
                let finalFood = editedFood
                onSave(finalFood)
                dismiss()
            }
        }
struct CategoryButtonExtended: View {
    let category: ManualFoodSelectionView.FoodCategoryExtended
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}
struct CompactFoodRow: View {
    let food: Food
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            // Icono de categoría más pequeño
            Image(systemName: food.category.icon)
                .font(.body)
                .foregroundColor(food.category.color)
                .frame(width: 20)
            
            // Información del alimento más compacta
            VStack(alignment: .leading, spacing: 2) {
                Text(food.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                // Solo mostrar los nutrientes más importantes
                HStack(spacing: 8) {
                    if food.fiberContent > 1 {
                        CompactNutrientLabel(icon: "leaf.fill", value: "\(String(format: "%.0f", food.fiberContent))g", color: .green)
                    }
                    if food.proteinContent > 5 {
                        CompactNutrientLabel(icon: "flame.fill", value: "\(String(format: "%.0f", food.proteinContent))g", color: .red)
                    }
                    if food.carbContent > 5 {
                        CompactNutrientLabel(icon: "bolt.fill", value: "\(String(format: "%.0f", food.carbContent))g", color: .orange)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Etiqueta de Nutriente Compacta
struct CompactNutrientLabel: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Header de Éxito Compacto
struct CompactSuccessHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("¡Orden Calculado!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Tu secuencia personalizada")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Tarjeta de Resultado Principal Compacta
struct CompactMainResultCard: View {
    let prediction: GlucosePrediction
    
    var body: some View {
        VStack(spacing: 15) {
            // Pico estimado en una sola línea
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Pico Estimado")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(prediction.estimatedPeak))")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(prediction.estimatedPeak > 140 ? .orange : .green)
                        
                        Text("mg/dL")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Confianza e indicador
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Confianza")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(Double(index) < prediction.confidence * 5 ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
            
            // Beneficio si hay reducción significativa
            if prediction.glucoseReduction > 10 {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                    
                    Text("Reducción: \(Int(prediction.glucoseReduction)) mg/dL")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - Orden Paso a Paso Compacto
struct CompactStepByStepOrder: View {
    let foods: [Food]
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tu Orden:")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
            
            // Lista compacta de pasos
            VStack(spacing: 8) {
                ForEach(Array(foods.enumerated()), id: \.offset) { index, food in
                    HStack(spacing: 12) {
                        // Número del paso más pequeño
                        ZStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 32, height: 32)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Información del alimento compacta
                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.displayName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(getCompactStepExplanation(for: food, step: index + 1))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        // Icono del tipo de alimento
                        Image(systemName: food.category.icon)
                            .font(.title3)
                            .foregroundColor(food.category.color)
                    }
                    .padding(.vertical, 6)
                }
            }
            
            // Explicación general más corta
            Text(explanation)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .lineLimit(3)
        }
        .padding(20)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func getCompactStepExplanation(for food: Food, step: Int) -> String {
        if food.fiberContent > 3.0 {
            return "Rica en fibra - ralentiza absorción"
        } else if food.proteinContent > 10.0 {
            return "Alta proteína - estabiliza glucosa"
        } else if food.carbContent > 15.0 {
            return step == 1 ? "Mejor después de fibra/proteína" : "Al final minimiza picos"
        } else {
            return "Complementa tu comida balanceada"
        }
    }
}

// MARK: - Grid de Acciones 2x2
struct ActionsGrid: View {
    let prediction: GlucosePrediction
    @ObservedObject var speechManager: SpeechManager
    let onSetupReminders: () -> Void
    let onSaveAndDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Fila 1: Usar SeniorFriendlyButton existente
            HStack(spacing: 15) {
                SeniorFriendlyButton(
                    title: "Escuchar Instrucciones",
                    subtitle: "Repetir en voz alta",
                    icon: "speaker.wave.3",
                    backgroundColor: .green,
                    size: .medium
                ) {
                    speechManager.announceOptimalOrder(prediction.recommendedOrder)
                }
            }
            
            // Fila 2: Recordatorios
            SeniorFriendlyButton(
                title: "Configurar Recordatorios",
                subtitle: "Para medir glucosa después",
                icon: "bell.badge",
                backgroundColor: .orange,
                size: .medium
            ) {
                onSetupReminders()
            }
            
            // Fila 3: Botón principal
            SeniorFriendlyButton(
                title: "Analizar Nueva Comida",
                subtitle: "Toca para comenzar",
                icon: "camera.viewfinder",
                backgroundColor: .blue,
                size: .large
            ) {
                 // ✅ Esta variable SÍ existe en DashboardView
            }        }
    }
}

// MARK: - Botón de Acción Compacto (si no existe ya)

// MARK: - Vista de Contador de Racha Saludable (AGREGAR AL FINAL DE SwiftChallengeApp.swift)
struct HealthyStreakView: View {
    @StateObject private var streakManager = HealthyStreakManager()
    @State private var showingResetAlert = false
    @State private var showingCelebration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header principal con contador
                    StreakCounterCard(
                        currentStreak: streakManager.currentStreak,
                        longestStreak: streakManager.longestStreak,
                        onCelebrate: {
                            showingCelebration = true
                        }
                    )
                    
                    // Progreso hacia metas
                    StreakProgressSection(
                        currentStreak: streakManager.currentStreak,
                        nextMilestone: streakManager.nextMilestone
                    )
                    
                    // Historial y estadísticas
                    StreakStatsSection(streakManager: streakManager)
                    
                    // Consejos y motivación
                    MotivationalSection(currentStreak: streakManager.currentStreak)
                    
                    // Botón de reinicio
                    ResetStreakSection(onReset: {
                        showingResetAlert = true
                    })
                    
                    Spacer(minLength: 50)
                }
                .padding(20)
            }
            .background(DesignSystem.backgroundCream)
            .navigationTitle("Racha Saludable")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reiniciar Racha", isPresented: $showingResetAlert) {
            Button("Reiniciar", role: .destructive) {
                streakManager.resetStreak()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro que quieres reiniciar tu racha a 0 días? Esta acción no se puede deshacer.")
        }
        .alert("🎉 ¡Felicitaciones!", isPresented: $showingCelebration) {
            Button("¡Genial!") { }
        } message: {
            Text("¡Has alcanzado \(streakManager.currentStreak) días sin alimentos procesados! ¡Sigue así!")
        }
    }
}

// MARK: - Tarjeta Principal del Contador
struct StreakCounterCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let onCelebrate: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Icono central animado
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.2), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("DÍAS")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .tracking(2)
                }
            }
            .onAppear {
                isAnimating = true
            }
            
            // Contador principal
            VStack(spacing: 10) {
                Text("\(currentStreak)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                Text("Días sin alimentos procesados")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Record personal
            if longestStreak > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.orange)
                    
                    Text("Récord personal: \(longestStreak) días")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
            
            // Botón de celebración
            if currentStreak > 0 {
                Button(action: onCelebrate) {
                    HStack(spacing: 10) {
                        Image(systemName: "party.popper.fill")
                            .foregroundColor(.purple)
                        
                        Text("¡Celebrar Logro!")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(15)
                }
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Sección de Progreso hacia Metas
struct StreakProgressSection: View {
    let currentStreak: Int
    let nextMilestone: Int
    
    private var progress: Double {
        if nextMilestone == 0 { return 1.0 }
        return min(1.0, Double(currentStreak) / Double(nextMilestone))
    }
    
    private var daysToGo: Int {
        max(0, nextMilestone - currentStreak)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Progreso hacia Meta")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(currentStreak)/\(nextMilestone)")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.blue)
            }
            
            // Barra de progreso
            VStack(spacing: 12) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                    .cornerRadius(6)
                
                HStack {
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(nextMilestone) días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Mensaje motivacional
            if daysToGo > 0 {
                Text("¡Solo \(daysToGo) días más para alcanzar tu próxima meta!")
                    .font(.body)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
            } else {
                Text("🎯 ¡Meta alcanzada! ¡Sigue así!")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Sección de Estadísticas
struct StreakStatsSection: View {
    @ObservedObject var streakManager: HealthyStreakManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Estadísticas")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Total de Días",
                    value: "\(streakManager.totalHealthyDays)",
                    icon: "calendar.badge.clock",
                    color: .blue
                )
                
                StatCard(
                    title: "Veces Reiniciado",
                    value: "\(streakManager.resetCount)",
                    icon: "arrow.clockwise",
                    color: .orange
                )
            }
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Promedio por Racha",
                    value: "\(streakManager.averageStreak)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
                
                StatCard(
                    title: "Días esta Semana",
                    value: "\(streakManager.daysThisWeek)",
                    icon: "calendar.badge.checkmark",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Tarjeta de Estadística Individual
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Sección Motivacional
struct MotivationalSection: View {
    let currentStreak: Int
    
    private var motivationalMessage: (title: String, message: String, icon: String, color: Color) {
        switch currentStreak {
        case 0:
            return ("¡Empezar es lo Más Difícil!", "Hoy es un gran día para comenzar tu racha saludable. Cada experto fue una vez un principiante.", "hand.raised.fill", .blue)
        case 1:
            return ("¡Primer Día Completado!", "¡Felicitaciones! Has dado el primer paso hacia una alimentación más saludable.", "star.fill", .yellow)
        case 2...6:
            return ("¡Construyendo Hábitos!", "Los primeros días son cruciales. Estás formando un hábito saludable que durará toda la vida.", "building.2.fill", .green)
        case 7...13:
            return ("¡Primera Semana!", "¡Una semana completa! Tu cuerpo ya está empezando a notar los beneficios.", "checkmark.seal.fill", .green)
        case 14...20:
            return ("¡Dos Semanas Fuertes!", "Tu disciplina es admirable. Los cambios positivos en tu salud son evidentes.", "flame.fill", .orange)
        case 21...29:
            return ("¡Casi un Mes!", "Estás muy cerca de completar un mes entero. Tu determinación es inspiradora.", "target", .purple)
        case 30...59:
            return ("¡Mes Completo!", "¡Un mes entero sin procesados! Eres un ejemplo de disciplina y salud.", "trophy.fill", .orange)
        case 60...89:
            return ("¡Dos Meses Increíbles!", "Dos meses es una hazaña impresionante. Tu salud está agradecida.", "medal.fill", .blue)
        case 90...179:
            return ("¡Tres Meses de Excelencia!", "Tres meses demuestran un compromiso serio con tu salud. ¡Extraordinario!", "crown.fill", .purple)
        case 180...364:
            return ("¡Medio Año de Salud!", "Seis meses es un logro monumental. Eres una inspiración para otros.", "gem", .green)
        default:
            return ("¡Leyenda Viviente!", "¡Un año o más! Eres un verdadero maestro de la alimentación saludable.", "sparkles", .yellow)
        }
    }
    
    var body: some View {
        let motivation = motivationalMessage
        
        VStack(spacing: 20) {
            HStack {
                Text("Motivación")
                    .font(DesignSystem.titleFont)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 15) {
                Image(systemName: motivation.icon)
                    .font(.system(size: 40))
                    .foregroundColor(motivation.color)
                
                Text(motivation.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(motivation.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
            .padding(25)
            .background(motivation.color.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Sección de Reinicio
struct ResetStreakSection: View {
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Zona de Reinicio")
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("¿Consumiste algo procesado?")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text("Si rompiste tu racha, reinicia el contador para empezar de nuevo.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                
                Button(action: onReset) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.body.weight(.semibold))
                        
                        Text("Reiniciar Contador")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
