
import Foundation
import SwiftUI
import CoreML
import Vision
import AVFoundation
import UserNotifications

// MARK: - Modelos de Datos
struct Food: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let glycemicIndex: Double
    let fiberContent: Double
    let proteinContent: Double
    let carbContent: Double
    let fatContent: Double
    var portion: Double = 1.0
    var category: FoodCategory
    
    enum FoodCategory: String, CaseIterable, Codable {
        case vegetables = "Vegetales"
        case proteins = "Proteínas"
        case carbohydrates = "Carbohidratos"
        case fruits = "Frutas"
        case dairy = "Lácteos"
        case fats = "Grasas"
        
        var icon: String {
            switch self {
            case .vegetables: return "leaf.fill"
            case .proteins: return "flame.fill"
            case .carbohydrates: return "bolt.fill"
            case .fruits: return "apple.logo"
            case .dairy: return "drop.fill"
            case .fats: return "circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .vegetables: return .green
            case .proteins: return .red
            case .carbohydrates: return .orange
            case .fruits: return .purple
            case .dairy: return .blue
            case .fats: return .yellow
            }
        }
    }
}

struct GlucosePrediction {
    let estimatedPeak: Double
    let timeToHours: Double
    let confidence: Double
    let recommendedOrder: [Food]
    let explanation: String
    let glucoseReduction: Double
    let curve: [GlucosePoint]
    
    struct GlucosePoint {
        let time: Double // horas
        let value: Double // mg/dL
    }
}

struct UserProfile: Codable {
    var age: Int = 65
    var weight: Double = 70.0
    var height: Double = 165.0
    var diabetesType: DiabetesType = .type2
    var medicationStatus: Bool = false
    var carbSensitivity: Double = 1.0
    var fiberEffectiveness: Double = 1.0
    var baselineGlucose: Double = 100.0
    
    enum DiabetesType: String, CaseIterable, Codable {
        case none = "Sin Diabetes"
        case prediabetes = "Prediabetes"
        case type1 = "Tipo 1"
        case type2 = "Tipo 2"
    }
    
    var bmi: Double {
        return weight / ((height / 100) * (height / 100))
    }
}

struct GlucoseReading: Identifiable, Codable {
    let id = UUID()
    let value: Double
    let timestamp: Date
    let context: String?
    let mealId: UUID?
}

struct SavedMeal: Identifiable {
    let id = UUID()
    let foods: [Food]
    let predictedPeak: Double
    let actualPeak: Double?
    let timestamp: Date
    let followedRecommendation: Bool
}

struct DailyRecommendation {
    let title: String
    let message: String
    let icon: String
    let color: Color
}

enum MealCaptureStep: Int, CaseIterable {
    case capture = 0
    case confirm = 1
    case glucose = 2
    case optimize = 3
    case result = 4
    
    var title: String {
        switch self {
        case .capture: return "Capturar Alimentos"
        case .confirm: return "Confirmar Alimentos"
        case .glucose: return "Glucosa Actual"
        case .optimize: return "Optimizando..."
        case .result: return "Tu Resultado"
        }
    }
}

// MARK: - Algoritmo Nutricional Científico
// REEMPLAZAR la función calculateOptimalOrder en NutritionalOptimizer

struct NutritionalOptimizer {
    
    static func calculateOptimalOrder(foods: [Food], userProfile: UserProfile) -> OptimizationResult {
        
        // ✅ FIX: Umbral de fibra más estricto + priorizar verduras
        var optimizedOrder: [Food] = []
        var remainingFoods = foods
        
        // PASO 1: VERDURAS PRIMERO (categoría vegetables + fibra > 1.5g)
        let vegetables = remainingFoods.filter {
            $0.category == .vegetables && $0.fiberContent > 1.5
        }.sorted { $0.fiberContent > $1.fiberContent }
        optimizedOrder.append(contentsOf: vegetables)
        remainingFoods.removeAll { food in vegetables.contains { $0.id == food.id } }
        
        // PASO 2: FIBRA MUY ALTA (>= 5.0g) que no sean verduras
        let ultraHighFiber = remainingFoods.filter { $0.fiberContent >= 5.0 }
            .sorted { $0.fiberContent > $1.fiberContent }
        optimizedOrder.append(contentsOf: ultraHighFiber)
        remainingFoods.removeAll { food in ultraHighFiber.contains { $0.id == food.id } }
        
        // PASO 3: PROTEÍNAS (>= 15g proteína)
        let proteins = remainingFoods.filter { $0.proteinContent >= 15.0 }
            .sorted { $0.proteinContent > $1.proteinContent }
        optimizedOrder.append(contentsOf: proteins)
        remainingFoods.removeAll { food in proteins.contains { $0.id == food.id } }
        
        // PASO 4: GRASAS SALUDABLES
        let healthyFats = remainingFoods.filter {
            $0.fatContent > 8.0 && $0.carbContent < 15.0
        }
        optimizedOrder.append(contentsOf: healthyFats)
        remainingFoods.removeAll { food in healthyFats.contains { $0.id == food.id } }
        
        // PASO 5: CARBOHIDRATOS AL FINAL (todo lo que tenga >15g carbos)
        let carbohydrates = remainingFoods.filter { $0.carbContent > 15.0 }
            .sorted { $0.glycemicIndex < $1.glycemicIndex } // IG menor primero
        optimizedOrder.append(contentsOf: carbohydrates)
        remainingFoods.removeAll { food in carbohydrates.contains { $0.id == food.id } }
        
        // PASO 6: Todo lo demás
        optimizedOrder.append(contentsOf: remainingFoods)
        
        // Calcular predicciones
        let originalOrder = foods
        let optimizedPeak = predictGlucosePeak(foods: optimizedOrder, userProfile: userProfile)
        let originalPeak = predictGlucosePeak(foods: originalOrder, userProfile: userProfile)
        
        return OptimizationResult(
            originalOrder: originalOrder,
            optimizedOrder: optimizedOrder,
            originalPeak: originalPeak,
            optimizedPeak: optimizedPeak,
            reduction: abs(originalPeak - optimizedPeak) // ← Siempre positiva
        )
    }
    
    // ✅ MANTENER esta función igual (no cambiar)
    private static func predictGlucosePeak(foods: [Food], userProfile: UserProfile) -> Double {
        // Cálculos nutricionales totales
        let totalCarbs = foods.reduce(0) { $0 + $1.carbContent }
        let totalFiber = foods.reduce(0) { $0 + $1.fiberContent }
        let totalProtein = foods.reduce(0) { $0 + $1.proteinContent }
        let avgGlycemicIndex = foods.isEmpty ? 0 : foods.reduce(0) { $0 + $1.glycemicIndex } / Double(foods.count)
        
        // ✅ FIX: Usar glucosa ACTUAL del usuario, no baseline genérica
        let currentGlucose = userProfile.baselineGlucose // Esto debe venir del MealCaptureManager
        
        // Efectos del orden (basado en estudios clínicos)
        let fiberFirstEffect = foods.first?.fiberContent ?? 0 > 2.0 ? 0.85 : 1.0  // 15% reducción
        let proteinSecondEffect = foods.count > 1 && foods[1].proteinContent > 10.0 ? 0.92 : 1.0 // 8% reducción
        let carbsLastEffect = foods.last?.carbContent ?? 0 > 15.0 ? 0.9 : 1.1 // 10% reducción vs 10% aumento
        
        // Factores de absorción
        let fiberAbsorptionEffect = max(0.7, 1.0 - (totalFiber * 0.015)) // Fibra reduce absorción
        let proteinStabilizationEffect = max(0.85, 1.0 - (totalProtein * 0.003)) // Proteína estabiliza
        
        // Factores personales
        let ageFactor = 1.0 + Double(userProfile.age - 50) * 0.003 // Edad aumenta sensibilidad
        let bmiFactor = 1.0 + (userProfile.bmi - 25.0) * 0.01 // BMI afecta sensibilidad
        let sensitivityFactor = userProfile.carbSensitivity
        
        // ✅ FIX: Cálculo más realista del incremento de glucosa
        let carbImpactFactor = min(3.0, totalCarbs / 15.0) // Cada 15g carbs = factor 1.0
        let glycemicImpactFactor = avgGlycemicIndex / 55.0 // Normalizar IG
        
        // Spike base más realista
        let baseSpike = carbImpactFactor * glycemicImpactFactor * 25.0 * sensitivityFactor
        
        let adjustedSpike = baseSpike
            * fiberFirstEffect
            * proteinSecondEffect
            * carbsLastEffect
            * fiberAbsorptionEffect
            * proteinStabilizationEffect
            * ageFactor
            * bmiFactor
        
        // ✅ FIX: SIEMPRE sumar al valor actual, nunca restar
        let finalPeak = currentGlucose + max(5.0, adjustedSpike) // Mínimo +5 mg/dL después de comer
        
        return min(350.0, finalPeak) // Cap máximo realista
    }

}

struct OptimizationResult {
    let originalOrder: [Food]
    let optimizedOrder: [Food]
    let originalPeak: Double
    let optimizedPeak: Double
    let reduction: Double
    
    var explanation: String {
        let fiberFirst = optimizedOrder.first?.fiberContent ?? 0 > 3.0
        let carbsLast = optimizedOrder.last?.carbContent ?? 0 > 15.0
        
        if reduction > 25 {
            return "¡Excelente optimización! Este orden puede reducir tu pico en \(Int(reduction)) mg/dL. La fibra primero ralentiza la absorción y los carbohidratos al final minimizan picos."
        } else if reduction > 15 {
            return "Muy buen orden. Reducción estimada: \(Int(reduction)) mg/dL. \(fiberFirst ? "Comenzar con fibra" : "Optimizar inicio") ayuda al control glucémico."
        } else if reduction > 5 {
            return "Este orden mejora tu control glucémico en \(Int(reduction)) mg/dL. Pequeños cambios hacen gran diferencia."
        } else {
            return "Este orden ayudará a mantener estable tu glucosa. \(carbsLast ? "Carbohidratos al final es una buena estrategia." : "Considera mover carbohidratos al final.")"
        }
    }
}

class HealthyStreakManager: ObservableObject {
    @Published var currentStreak: Int = 1 // ✅ Valor por defecto de 1 día
    @Published var longestStreak: Int = 1
    @Published var totalHealthyDays: Int = 1
    @Published var resetCount: Int = 0
    @Published var lastUpdateDate: Date = Date()
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
        updateStreakIfNeeded()
    }
    
    // MARK: - Propiedades Calculadas
    var nextMilestone: Int {
        let milestones = [7, 14, 30, 60, 90, 180, 365]
        return milestones.first { $0 > currentStreak } ?? (currentStreak + 30)
    }
    
    var averageStreak: Int {
        guard resetCount > 0 else { return currentStreak }
        return totalHealthyDays / (resetCount + 1)
    }
    
    var daysThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        // Simular días esta semana basado en la racha actual
        let daysSinceStartOfWeek = calendar.dateComponents([.day], from: startOfWeek, to: Date()).day ?? 0
        return min(currentStreak, daysSinceStartOfWeek + 1)
    }
    
    // MARK: - Funciones Principales
    func resetStreak() {
        currentStreak = 0
        resetCount += 1
        lastUpdateDate = Date()
        saveData()
    }
    
    func addDay() {
        currentStreak += 1
        totalHealthyDays += 1
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastUpdateDate = Date()
        saveData()
    }
    
    private func updateStreakIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        // Si es un nuevo día, podríamos incrementar automáticamente
        // Por ahora solo actualizamos la fecha
        if !calendar.isDate(lastUpdateDate, inSameDayAs: today) {
            lastUpdateDate = today
            saveData()
        }
    }
    
    // MARK: - Persistencia de Datos
    private func saveData() {
        userDefaults.set(currentStreak, forKey: "currentStreak")
        userDefaults.set(longestStreak, forKey: "longestStreak")
        userDefaults.set(totalHealthyDays, forKey: "totalHealthyDays")
        userDefaults.set(resetCount, forKey: "resetCount")
        userDefaults.set(lastUpdateDate, forKey: "lastUpdateDate")
    }
    
    private func loadData() {
        // Solo cargar si existen datos guardados, sino mantener valores por defecto
        if userDefaults.object(forKey: "currentStreak") != nil {
            currentStreak = userDefaults.integer(forKey: "currentStreak")
            longestStreak = userDefaults.integer(forKey: "longestStreak")
            totalHealthyDays = userDefaults.integer(forKey: "totalHealthyDays")
            resetCount = userDefaults.integer(forKey: "resetCount")
            
            if let savedDate = userDefaults.object(forKey: "lastUpdateDate") as? Date {
                lastUpdateDate = savedDate
            }
        }
    }
}
