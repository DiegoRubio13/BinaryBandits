import SwiftUI
import CoreML
import Vision
import AVFoundation


// MARK: - App Principal
@main
struct GlucoOrderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Vista Principal con TabView
struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var glucoseManager = GlucoseManager()
    @StateObject private var speechManager = SpeechManager()
    
    var body: some View {
        // En ContentView.swift, reemplaza tu TabView existente por:

        TabView(selection: $appState.selectedTab) {
            // Tab 1: Dashboard/Inicio
            DashboardView(
                glucoseManager: glucoseManager,
                speechManager: speechManager
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Inicio")
            }
            .tag(0)
            
            // Tab 2: Nueva Comida
            NewMealView(
                glucoseManager: glucoseManager,
                speechManager: speechManager
            )
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Nueva Comida")
            }
            .tag(1)
            
            // Tab 3: Racha Saludable ✅ NUEVO
            HealthyStreakView()
            .tabItem {
                Image(systemName: "leaf.fill")
                Text("Racha")
            }
            .tag(2)
            
            // Tab 4: Historial
            HistoryView(glucoseManager: glucoseManager)
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Historial")
            }
            .tag(3)
            
            // Tab 5: Perfil
            ProfileView(glucoseManager: glucoseManager)
            .tabItem {
                Image(systemName: "person.fill")
                Text("Perfil")
            }
            .tag(4)
        }
        .accentColor(.blue)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Dashboard Principal
struct DashboardView: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @ObservedObject var speechManager: SpeechManager
    @State private var showingMealCapture = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Saludo personalizado
                    GreetingCard()
                    
                    // Estado actual de glucosa
                    CurrentGlucoseCard(
                        reading: glucoseManager.currentReading,
                        trend: glucoseManager.glucoseTrend
                    )
                    
                    // ✅ BOTÓN CORRECTO:
                    SeniorFriendlyButton(
                        title: "Analizar Nueva Comida",
                        subtitle: "Toca para comenzar",
                        icon: "camera.viewfinder",
                        backgroundColor: .blue,
                        size: .large
                    ) {
                        showingMealCapture = true
                    }
                    
                    // Recomendación del día
                    if let recommendation = glucoseManager.todayRecommendation {
                        TodayRecommendationCard(recommendation: recommendation)
                    }
                    
                    // Acciones rápidas
                    QuickActionsGrid(
                        glucoseManager: glucoseManager,
                        speechManager: speechManager
                    )
                    
                    // Resumen reciente
                    RecentSummaryCard(readings: glucoseManager.recentReadings)
                }
                .padding(20)
            }
            .background(DesignSystem.backgroundCream)
            .navigationTitle("FirstBite")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingMealCapture) {
            NewMealView(
                glucoseManager: glucoseManager,
                speechManager: speechManager
            )
        }
    }
}
// MARK: - Nueva Comida (Flujo Completo)
// MARK: - Nueva Comida (Flujo Completo) - ACTUALIZADO
struct NewMealView: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @ObservedObject var speechManager: SpeechManager
    
    @StateObject private var mealCapture = MealCaptureManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {  // ✅ Sin spacing entre elementos principales
                
                // ✅ 1. Barra de progreso ARRIBA
                ProgressBar(
                    currentStep: mealCapture.currentStep.rawValue,
                    totalSteps: MealCaptureStep.allCases.count
                )
                
                // ✅ 2. Contenido principal con scroll
                ScrollView {
                    VStack(spacing: 20) {
                        // Vista del paso actual
                        Group {
                            switch mealCapture.currentStep {
                            case .capture:
                                MealCaptureStepView(mealCapture: mealCapture)
                            case .confirm:
                                FoodConfirmationStepView(mealCapture: mealCapture)
                            case .glucose:
                                GlucoseInputStepView(
                                    mealCapture: mealCapture,
                                    glucoseManager: glucoseManager
                                )
                            case .optimize:
                                OptimizationStepView(
                                    mealCapture: mealCapture,
                                    glucoseManager: glucoseManager
                                )
                            case .result:
                                ResultStepView(
                                    mealCapture: mealCapture,
                                    speechManager: speechManager,
                                    glucoseManager: glucoseManager
                                )
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                        // ✅ Espaciador para empujar botones abajo
                        Spacer()
                            .frame(minHeight: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)  // ✅ Poco espacio entre progress y contenido
                }
                
                // ✅ 3. Botones de navegación FIJOS abajo
                VStack(spacing: 0) {
                    Divider() // ✅ Línea separadora
                    
                    NavigationButtons(
                        canGoBack: mealCapture.canGoBack,
                        canGoForward: true,
                        backTitle: "Atrás",
                        forwardTitle: mealCapture.forwardButtonTitle,
                        onBack: { mealCapture.goBack() },
                        onForward: {
                            if mealCapture.currentStep == .result {
                                dismiss()
                            } else {
                                mealCapture.goForward()
                            }
                        }
                    )
                    .padding(.top, 15)
                    .padding(.bottom, 30)  // ✅ Espacio para safe area
                    .background(Color.white)  // ✅ Fondo blanco para los botones
                }
            }
            .background(DesignSystem.backgroundCream)
            .navigationTitle("Nueva Comida")
            .navigationBarTitleDisplayMode(.inline)  // ✅ INLINE para menos espacio
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            mealCapture.initializeCurrentGlucose(from: glucoseManager)
            speechManager.announceStep(mealCapture.currentStep)
        }
        .onChange(of: mealCapture.currentStep) { step in
            speechManager.announceStep(step)
        }
    }
}

// MARK: - Paso 1: Captura de Alimentos con ML REAL
struct MealCaptureStepView: View {
    @ObservedObject var mealCapture: MealCaptureManager
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var foodRecognizer = EnhancedFoodRecognizer()
    
    var body: some View {
        VStack(spacing: 20) {
            // Selector de método
            CaptureMethodSelector(
                selectedMethod: $mealCapture.captureMethod
            )
            
            // Contenido dinámico
            if mealCapture.captureMethod == .camera {
                // MODO CÁMARA CON ML REAL
                VStack(spacing: 20) {
                    InstructionCard(
                        title: "🤖 Cámara Inteligente",
                        instruction: "Nuestra IA identificará automáticamente los alimentos en tu foto",
                        icon: "brain.head.profile"
                    )
                    
                    // Vista de cámara mejorada
                    CameraView(
                        cameraManager: cameraManager,
                        foodRecognizer: foodRecognizer
                    ) { image in
                        handleImageCapture(image)
                    }
                    
                    // Mostrar resultados de ML si los hay
                    if !foodRecognizer.recognizedFoods.isEmpty {
                        MLResultsSection(
                            foodRecognizer: foodRecognizer,
                            onConfirmSelection: { selectedFoods in
                                mealCapture.detectedFoods = selectedFoods
                                // Auto-avanzar si el usuario confirma
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if mealCapture.canGoForward {
                                        // Opcional: auto-avanzar al siguiente paso
                                        // mealCapture.goForward()
                                    }
                                }
                            }
                        )
                    }
                }
            } else {
                // MODO MANUAL (mejorado)
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selección Manual")
                                .font(DesignSystem.titleFont)
                                .foregroundColor(.primary)
                            
                            Text("Busca y selecciona tus alimentos")
                                .font(DesignSystem.captionFont)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Contador de alimentos seleccionados
                        if !mealCapture.detectedFoods.isEmpty {
                            Text("\(mealCapture.detectedFoods.count)")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 5)
                    
                    ManualFoodSelectionView(
                        selectedFoods: $mealCapture.detectedFoods
                    )
                    .frame(height: 400)
                }
            }
        }
        .padding(.vertical, 10)
        .onAppear {
            // Limpiar detección anterior
            foodRecognizer.reset()
            mealCapture.detectedFoods = []
        }
        .onChange(of: foodRecognizer.recognizedFoods) { foods in
            // Actualizar automáticamente los alimentos detectados
            if !foods.isEmpty {
                mealCapture.detectedFoods = foods
            }
        }
    }
    
    private func handleImageCapture(_ image: UIImage) {
        mealCapture.originalImage = image
        // La detección ML se maneja automáticamente en foodRecognizer
    }
}

// MARK: - Sección de Resultados de ML
struct MLResultsSection: View {
    @ObservedObject var foodRecognizer: EnhancedFoodRecognizer
    let onConfirmSelection: ([Food]) -> Void
    
    @State private var selectedFoods: Set<String> = []
    
    var body: some View {
        VStack(spacing: 15) {
            // Header con estadísticas
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("🧠 IA Detectó Alimentos")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Selecciona los que vas a comer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Indicador de calidad de detección
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Precisión")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(Double(index) < foodRecognizer.confidence * 5 ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
            
            // Lista de alimentos detectados
            VStack(spacing: 10) {
                ForEach(foodRecognizer.recognizedFoods) { food in
                    MLFoodSelectionRow(
                        food: food,
                        isSelected: selectedFoods.contains(food.id.uuidString),
                        confidence: getConfidenceForFood(food),
                        onToggle: { isSelected in
                            if isSelected {
                                selectedFoods.insert(food.id.uuidString)
                            } else {
                                selectedFoods.remove(food.id.uuidString)
                            }
                        }
                    )
                }
            }
            
            // Botones de acción
            HStack(spacing: 15) {
                // Botón seleccionar todos
                Button(action: {
                    if selectedFoods.count == foodRecognizer.recognizedFoods.count {
                        selectedFoods.removeAll()
                    } else {
                        selectedFoods = Set(foodRecognizer.recognizedFoods.map { $0.id.uuidString })
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: selectedFoods.count == foodRecognizer.recognizedFoods.count ? "checkmark.square" : "square")
                        Text(selectedFoods.count == foodRecognizer.recognizedFoods.count ? "Deseleccionar" : "Seleccionar Todo")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Botón confirmar selección
                Button(action: {
                    let finalSelection = foodRecognizer.recognizedFoods.filter { food in
                        selectedFoods.contains(food.id.uuidString)
                    }
                    onConfirmSelection(finalSelection)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Confirmar (\(selectedFoods.count))")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(selectedFoods.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(8)
                }
                .disabled(selectedFoods.isEmpty)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            // Auto-seleccionar todos los alimentos detectados por defecto
            selectedFoods = Set(foodRecognizer.recognizedFoods.map { $0.id.uuidString })
        }
    }
    
    private func getConfidenceForFood(_ food: Food) -> Float {
        // Buscar la confianza específica de este alimento en las detecciones ML
        if let detection = foodRecognizer.detectedFoods.first(where: { $0.food.id == food.id }) {
            return detection.confidence
        }
        return Float(foodRecognizer.confidence) // Usar confianza general como fallback
    }
}

// MARK: - Fila de Selección de Alimento ML
struct MLFoodSelectionRow: View {
    let food: Food
    let isSelected: Bool
    let confidence: Float
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Checkbox con animación
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            
            // Icono de categoría
            ZStack {
                Circle()
                    .fill(food.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: food.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(food.category.color)
            }
            
            // Información del alimento
            VStack(alignment: .leading, spacing: 4) {
                Text(food.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    // Información nutricional clave
                    if food.fiberContent > 1 {
                        NutrientBadge(icon: "leaf.fill", value: "\(Int(food.fiberContent))g", color: .green)
                    }
                    if food.proteinContent > 5 {
                        NutrientBadge(icon: "flame.fill", value: "\(Int(food.proteinContent))g", color: .red)
                    }
                    if food.carbContent > 5 {
                        NutrientBadge(icon: "bolt.fill", value: "\(Int(food.carbContent))g", color: .orange)
                    }
                }
            }
            
            Spacer()
            
            // Badge de confianza ML
            VStack(spacing: 4) {
                Text("IA")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                
                Text("\(Int(confidence * 100))%")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(confidenceColor(confidence))
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func confidenceColor(_ confidence: Float) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Badge de Nutriente Pequeño
struct NutrientBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}
// MARK: - Paso 2: Confirmación de Alimentos
struct FoodConfirmationStepView: View {
    @ObservedObject var mealCapture: MealCaptureManager
    @State private var editingFood: Food?
    
    var body: some View {
        VStack(spacing: 25) {
            InstructionCard(
                title: "Confirma tus Alimentos",
                instruction: "Verifica que todos los alimentos sean correctos",
                icon: "checkmark.circle"
            )
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(mealCapture.detectedFoods) { food in
                        FoodConfirmationRow(
                            food: food,
                            isSelected: mealCapture.confirmedFoods.contains { $0.id == food.id },
                            onToggle: { isSelected in
                                toggleFoodSelection(food, isSelected: isSelected)
                            },
                            onEdit: {
                                editingFood = food
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Botón para agregar alimento manualmente
            SeniorFriendlyButton(
                title: "Agregar Alimento",
                subtitle: "¿Falta algo?",
                icon: "plus.circle",
                backgroundColor: .green,
                size: .medium
            ) {
                // Agregar alimento manual
                let newFood = AdvancedFoodDatabase.shared.mexicanFoods.values.randomElement()
                if let food = newFood {
                    mealCapture.detectedFoods.append(food)
                }
            }
        }
        .sheet(item: $editingFood) { food in
            FoodEditView(food: food) { editedFood in
                updateFood(editedFood)
            }
        }
    }
    
    private func toggleFoodSelection(_ food: Food, isSelected: Bool) {
        if isSelected {
            mealCapture.confirmedFoods.append(food)
        } else {
            mealCapture.confirmedFoods.removeAll { $0.id == food.id }
        }
    }
    
    private func updateFood(_ food: Food) {
        if let index = mealCapture.confirmedFoods.firstIndex(where: { $0.id == food.id }) {
            mealCapture.confirmedFoods[index] = food
        }
    }
}

// MARK: - Paso 3: Entrada de Glucosa Actual
// MARK: - Paso 3: Entrada de Glucosa Actual (ACTUALIZADO)
// MARK: - Paso 3: Entrada de Glucosa Actual (ACTUALIZADO)
struct GlucoseInputStepView: View {
    @ObservedObject var mealCapture: MealCaptureManager
    @ObservedObject var glucoseManager: GlucoseManager
    
    @State private var glucoseText = ""
    @State private var useLastReading = true
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionCard(
                title: "Tu Glucosa Actual",
                instruction: "Necesitamos saber tu nivel actual para hacer la mejor predicción",
                icon: "drop.circle"
            )
            
            // Opción de usar última lectura
            if let lastReading = mealCapture.getLastGlucoseReading(from: glucoseManager) {
                LastReadingCard(
                    reading: lastReading,
                    isSelected: useLastReading,
                    onToggle: { newValue in
                        useLastReading = newValue
                    }
                )
            } else {
                // Si no hay lectura reciente, mostrar mensaje
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("No hay lecturas recientes")
                        .font(DesignSystem.titleFont)
                        .foregroundColor(.secondary)
                    
                    Text("Ingresa tu glucosa actual manualmente")
                        .font(DesignSystem.bodyFont)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
            }
            
            // Entrada manual
            if !useLastReading {
                VStack(spacing: 20) {
                    Text("Ingresa tu glucosa actual:")
                        .font(DesignSystem.titleFont)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("100", text: $glucoseText)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("mg/dL")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            // Recordatorio de medición
            ReminderCard(
                title: "💡 Consejo",
                message: "Para mejores resultados, mide tu glucosa justo antes de comer"
            )
        }
        .onAppear {
            initializeGlucoseValues()
        }
        .onChange(of: glucoseText) { value in
            if let glucose = Double(value) {
                mealCapture.currentGlucose = glucose
            }
        }
        .onChange(of: useLastReading) { value in
            updateGlucoseFromSelection()
        }
    }
    
    private func initializeGlucoseValues() {
        if let lastReading = mealCapture.getLastGlucoseReading(from: glucoseManager) {
            useLastReading = true
            mealCapture.currentGlucose = lastReading.value
            glucoseText = "\(Int(lastReading.value))"
        } else {
            useLastReading = false
            glucoseText = ""
        }
    }
    
    private func updateGlucoseFromSelection() {
        if useLastReading {
            if let lastReading = mealCapture.getLastGlucoseReading(from: glucoseManager) {
                mealCapture.currentGlucose = lastReading.value
                glucoseText = "\(Int(lastReading.value))"
            }
        } else {
            if glucoseText.isEmpty {
                glucoseText = ""
            }
        }
    }
}
// MARK: - Paso 4: Optimización (ML en acción)
struct OptimizationStepView: View {
    @ObservedObject var mealCapture: MealCaptureManager
    @ObservedObject var glucoseManager: GlucoseManager
    @StateObject private var optimizer = SmartGlucoseOptimizer()
    
    var body: some View {
        VStack(spacing: 30) {
            if optimizer.isProcessing {
                ProcessingView()
            } else if let prediction = mealCapture.prediction {
                OptimizationResultView(prediction: prediction)
            } else {
                Text("Iniciando optimización...")
                    .font(DesignSystem.titleFont)
            }
        }
        .onAppear {
            optimizeMealOrder()
        }
    }
    
    private func optimizeMealOrder() {
        Task {
            let prediction = await optimizer.optimizeMealOrder(
                foods: mealCapture.confirmedFoods,
                currentGlucose: mealCapture.currentGlucose,
                userProfile: glucoseManager.userProfile
            )
            
            DispatchQueue.main.async {
                mealCapture.prediction = prediction
            }
        }
    }
}

// MARK: - Paso 5: Resultado Final
// MARK: - Paso 5: Resultado Final (ACTUALIZADO)
struct ResultStepView: View {
    @ObservedObject var mealCapture: MealCaptureManager
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var glucoseManager: GlucoseManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let prediction = mealCapture.prediction {
                    CompactSuccessHeader()
                    CompactMainResultCard(prediction: prediction)
                    CompactStepByStepOrder(
                        foods: prediction.recommendedOrder,
                        explanation: prediction.explanation
                    )
                    
                    // ✅ NUEVO: Botones directos
                    VStack(spacing: 15) {
                        SeniorFriendlyButton(
                            title: "Escuchar Instrucciones",
                            subtitle: "Repetir en voz alta",
                            icon: "speaker.wave.3",
                            backgroundColor: .green,
                            size: .medium
                        ) {
                            speechManager.announceOptimalOrder(prediction.recommendedOrder)
                        }
                        
                        SeniorFriendlyButton(
                            title: "Configurar Recordatorios",
                            subtitle: "Para medir glucosa después",
                            icon: "bell.badge",
                            backgroundColor: .orange,
                            size: .medium
                        ) {
                            setupGlucoseReminders()
                        }
                        
                        SeniorFriendlyButton(
                            title: "¡Perfecto, Comenzar a Comer!",
                            subtitle: "Guardar",
                            icon: "checkmark.circle.fill",
                            backgroundColor: .blue,
                            size: .large
                        ) {
                            saveMealAndDismiss()
                        }
                    }
                }
            }
            .padding(20)
        }
        .onAppear {
            if let prediction = mealCapture.prediction {
                speechManager.savePrediction(prediction)
            }
        }
    }
    
    private func setupGlucoseReminders() {
        NotificationManager.shared.scheduleGlucoseReminders()
        speechManager.speak("Recordatorios configurados. Te avisaré cuando sea hora de medir tu glucosa.")
    }
    
    private func saveMealAndDismiss() {
        if let prediction = mealCapture.prediction {
            let preReading = GlucoseReading(
                value: mealCapture.currentGlucose,
                timestamp: Date().addingTimeInterval(-10),
                context: "Pre-comida",
                mealId: UUID()
            )
            
            let postReading = GlucoseReading(
                value: prediction.estimatedPeak,
                timestamp: Date(),
                context: "Post-comida (predicción)",
                mealId: UUID()
            )
            
            glucoseManager.addGlucoseReading(preReading)
            glucoseManager.addGlucoseReading(postReading)
            
            SimpleDataManager.shared.saveMeal(SavedMeal(
                foods: prediction.recommendedOrder,
                predictedPeak: prediction.estimatedPeak,
                actualPeak: nil,
                timestamp: Date(),
                followedRecommendation: true
            ))
            
            speechManager.announceMotivationalMessage()
        }
        dismiss()
    }
}

// MARK: - Vista de Historial
struct HistoryView: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case threeMonths = "3 Meses"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Selector de rango de tiempo
                Picker("Rango", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Gráfica principal
                        GlucoseChart(
                            readings: filteredReadings,
                            timeRange: selectedTimeRange
                        )
                        
                        // Estadísticas resumidas
                        StatsSummaryCard(readings: filteredReadings)
                        
                        // Lista de comidas recientes
                        RecentMealsSection(meals: glucoseManager.recentMeals)
                        
                        // Tendencias y patrones
                        PatternsSection(readings: filteredReadings)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(DesignSystem.backgroundCream)
            .navigationTitle("Mi Historial")
        }
    }
    
    private var filteredReadings: [GlucoseReading] {
        let calendar = Calendar.current
        let now = Date()
        let cutoffDate: Date
        
        switch selectedTimeRange {
        case .week:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return glucoseManager.allReadings.filter { $0.timestamp >= cutoffDate }
    }
}

// MARK: - Vista de Perfil
struct ProfileView: View {
    @ObservedObject var glucoseManager: GlucoseManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Información del usuario
                    UserInfoCard(profile: glucoseManager.userProfile) {
                        showingEditProfile = true
                    }
                    
                    // Estadísticas personales
                    PersonalStatsCard(
                        profile: glucoseManager.userProfile,
                        recentReadings: glucoseManager.recentReadings
                    )
                    
                    // Configuraciones
                    SettingsSection()
                    
                    // Información y ayuda
                    HelpSection()
                }
                .padding(20)
            }
            .background(DesignSystem.backgroundCream)
            .navigationTitle("Mi Perfil")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(profile: $glucoseManager.userProfile)
        }
    }
}

// MARK: - ReminderCard (Componente Faltante)
// MARK: - ReminderCard
struct ReminderCard: View {
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(DesignSystem.bodyFont.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(DesignSystem.bodyFont)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(15)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - InstructionCard (Asegurar que existe)
struct InstructionCard: View {
    let title: String
    let instruction: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(title)
                .font(DesignSystem.titleFont)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(instruction)
                .font(DesignSystem.bodyFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - CLASES CORREGIDAS - AGREGAR AL FINAL DE ContentView.swift

// MARK: - Managers
class AppState: ObservableObject {
    @Published var selectedTab = 0
    @Published var isFirstLaunch = true
}

class MealCaptureManager: ObservableObject {
    @Published var currentStep: MealCaptureStep = .capture
    @Published var captureMethod: CaptureMethod = .camera
    @Published var detectedFoods: [Food] = []
    @Published var confirmedFoods: [Food] = []
    @Published var currentGlucose: Double = 100.0
    @Published var prediction: GlucosePrediction?
    @Published var originalImage: UIImage?
    
    enum CaptureMethod {
        case camera, manual
    }
    
    var canGoBack: Bool {
        currentStep != .capture
    }
    
    var canGoForward: Bool {
        switch currentStep {
        case .capture:
            return !detectedFoods.isEmpty
        case .confirm:
            return !confirmedFoods.isEmpty
        case .glucose:
            return currentGlucose > 0
        case .optimize:
            return prediction != nil
        case .result:
            return true                            // ✅ SIEMPRE habilitado
        }
    }
    
    var forwardButtonTitle: String {
        switch currentStep {
        case .capture: return "Continuar"
        case .confirm: return "Confirmar"
        case .glucose: return "Calcular"
        case .optimize: return "Ver Resultado"
        case .result: return "Finalizar"
        }
    }
    
    func getLastGlucoseReading(from glucoseManager: GlucoseManager) -> GlucoseReading? {
        return glucoseManager.currentReading ?? glucoseManager.recentReadings.first
    }
    
    func initializeCurrentGlucose(from glucoseManager: GlucoseManager) {
        if let lastReading = getLastGlucoseReading(from: glucoseManager) {
            currentGlucose = lastReading.value
        } else {
            currentGlucose = 100.0
        }
    }
    
    func goBack() {
        if let previousStep = MealCaptureStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    func goForward() {
        if let nextStep = MealCaptureStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    func resetForNewMeal() {
        currentStep = .capture
        detectedFoods = []
        confirmedFoods = []
        prediction = nil
        originalImage = nil
    }
}

class GlucoseManager: ObservableObject {
    @Published var userProfile = UserProfile()
    @Published var currentReading: GlucoseReading?
    @Published var recentReadings: [GlucoseReading] = []
    @Published var allReadings: [GlucoseReading] = []
    @Published var recentMeals: [SavedMeal] = []
    @Published var todayRecommendation: DailyRecommendation?
    
    internal var isFirstRealReading = true  // Controla cuándo limpiar datos de muestra
    
    var glucoseTrend: CurrentGlucoseCard.GlucoseTrend {
        guard recentReadings.count >= 2 else { return .stable }
        
        let recent = recentReadings.prefix(2)
        let current = recent.first!.value
        let previous = recent.last!.value
        let difference = current - previous
        
        if difference > 10 {
            return .rising
        } else if difference < -10 {
            return .falling
        } else {
            return .stable
        }
    }
    
    init() {
        loadSampleData()
        generateTodayRecommendation()
    }
    
    private func loadSampleData() {
        let sampleReadings = [
            GlucoseReading(value: 105, timestamp: Date().addingTimeInterval(-3600), context: "Pre-comida", mealId: UUID()),
            GlucoseReading(value: 142, timestamp: Date().addingTimeInterval(-1800), context: "Post-comida", mealId: UUID()),
            GlucoseReading(value: 98, timestamp: Date().addingTimeInterval(-900), context: "Actual", mealId: UUID())
        ]
        
        self.recentReadings = sampleReadings
        self.allReadings = sampleReadings
        self.currentReading = sampleReadings.last
        
        let sampleMeals = [
            SavedMeal(
                foods: AdvancedFoodDatabase.shared.getRandomMealCombination(),
                predictedPeak: 145,
                actualPeak: 148,
                timestamp: Date().addingTimeInterval(-86400),
                followedRecommendation: true
            ),
            SavedMeal(
                foods: AdvancedFoodDatabase.shared.getRandomMealCombination(),
                predictedPeak: 155,
                actualPeak: nil,
                timestamp: Date().addingTimeInterval(-43200),
                followedRecommendation: false
            )
        ]
        
        self.recentMeals = sampleMeals
    }
    
    private func generateTodayRecommendation() {
        todayRecommendation = DailyRecommendation(
            title: "Recomendación del Día",
            message: "Intenta comenzar tus comidas con vegetales o ensalada para mejor control glucémico",
            icon: "leaf.fill",
            color: .green
        )
    }
    
    func addGlucoseReading(_ reading: GlucoseReading) {
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

    
}

class SpeechManager: ObservableObject {
    internal let speechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var lastOptimalOrder: [Food]? = nil
    @Published var lastPrediction: GlucosePrediction? = nil
    @Published var hasLastInstructions: Bool = false
    
    func announceStep(_ step: MealCaptureStep) {
        let message: String
        
        switch step {
        case .capture:
            message = "Paso 1: Toma una foto de tu comida o selecciona los alimentos manualmente"
        case .confirm:
            message = "Paso 2: Confirma que los alimentos detectados son correctos"
        case .glucose:
            message = "Paso 3: Ingresa tu nivel de glucosa actual"
        case .optimize:
            message = "Paso 4: Calculando el mejor orden para tu comida"
        case .result:
            message = "¡Listo! Aquí está tu orden personalizado"
        }
        
        speak(message)
    }
    
    func announceOptimalOrder(_ foods: [Food]) {
        lastOptimalOrder = foods
        hasLastInstructions = true
        
        var message = "Tu orden recomendado es: "
        
        for (index, food) in foods.enumerated() {
            message += "\(index + 1). \(food.displayName)"
            if index < foods.count - 1 {
                message += ", después "
            }
        }
        
        message += ". Seguir este orden puede ayudarte a mantener mejor control de tu glucosa."
        speak(message)
    }
    
    func savePrediction(_ prediction: GlucosePrediction) {
        lastPrediction = prediction
        lastOptimalOrder = prediction.recommendedOrder
        hasLastInstructions = true
    }
    
    func repeatLastInstructions() {
        guard hasLastInstructions else {
            speak("No hay instrucciones previas para repetir. Primero analiza una comida.")
            return
        }
        
        if let foods = lastOptimalOrder {
            var message = "Repitiendo tu orden personalizado: "
            
            for (index, food) in foods.enumerated() {
                let stepNumber = index + 1
                message += "\(stepNumber). \(food.displayName)"
                
                let explanation = getStepExplanation(for: food, step: stepNumber)
                message += " - \(explanation)"
                
                if index < foods.count - 1 {
                    message += ". Después, "
                }
            }
            
            if let prediction = lastPrediction, prediction.glucoseReduction > 10 {
                message += ". Recuerda: este orden puede reducir tu pico de glucosa en \(Int(prediction.glucoseReduction)) miligramos por decilitro."
            }
            
            message += " ¡Buen provecho!"
            speak(message)
        } else {
            speak("No se encontraron instrucciones previas. Analiza una nueva comida primero.")
        }
    }
    
    private func getStepExplanation(for food: Food, step: Int) -> String {
        if food.fiberContent > 3.0 {
            return "rica en fibra, ayuda a ralentizar la absorción"
        } else if food.proteinContent > 10.0 {
            return "alta en proteína, estabiliza la glucosa"
        } else if food.carbContent > 15.0 {
            return step == 1 ? "intenta comerlo después de fibra y proteína" : "al final para minimizar picos"
        } else {
            return "complementa perfectamente tu comida balanceada"
        }
    }
    
    func announceMotivationalMessage() {
        let messages = [
            "¡Excelente trabajo siguiendo tu orden personalizado!",
            "Estás tomando control de tu salud, ¡sigue así!",
            "Cada comida ordenada es un paso hacia mejor control glucémico",
            "Tu disciplina hoy significa mejor salud mañana"
        ]
        
        let randomMessage = messages.randomElement() ?? messages[0]
        speak(randomMessage)
    }
    
    func clearLastInstructions() {
        lastOptimalOrder = nil
        lastPrediction = nil
        hasLastInstructions = false
    }
    
    // ✅ FUNCIÓN SPEAK - SOLO UNA VERSIÓN
    
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

class SmartGlucoseOptimizer: ObservableObject {
    @Published var isProcessing = false
    
    func optimizeMealOrder(
        foods: [Food],
        currentGlucose: Double,
        userProfile: UserProfile
    ) async -> GlucosePrediction {
        
        isProcessing = true
        defer { isProcessing = false }
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // ✅ CLAVE: Pasar la glucosa actual al algoritmo
        var modifiedProfile = userProfile
        modifiedProfile.baselineGlucose = currentGlucose // ← ESTO es lo importante
        
        let result = NutritionalOptimizer.calculateOptimalOrder(
            foods: foods,
            userProfile: modifiedProfile // ← Usar el perfil con glucosa actualizada
        )
        
        let curve = generateGlucoseCurve(
            baseline: currentGlucose, // ← Usar glucosa actual aquí también
            peak: result.optimizedPeak
        )
        
        return GlucosePrediction(
            estimatedPeak: result.optimizedPeak,
            timeToHours: 1.5,
            confidence: 0.87,
            recommendedOrder: result.optimizedOrder,
            explanation: result.explanation,
            glucoseReduction: result.reduction,
            curve: curve
        )
    }
    
    private func generateGlucoseCurve(baseline: Double, peak: Double) -> [GlucosePrediction.GlucosePoint] {
        var points: [GlucosePrediction.GlucosePoint] = []
        
        for i in 0...24 {
            let time = Double(i) * 10.0 / 60.0
            let value: Double
            
            if time < 0.5 {
                value = baseline + (peak - baseline) * (time / 0.5) * 0.3
            } else if time < 1.5 {
                let peakTime = 1.0
                let distanceFromPeak = abs(time - peakTime)
                value = baseline + (peak - baseline) * exp(-distanceFromPeak * 2.0)
            } else {
                let decayFactor = exp(-(time - 1.5) * 0.8)
                value = baseline + (peak - baseline) * 0.4 * decayFactor
            }
            
            points.append(GlucosePrediction.GlucosePoint(time: time, value: max(baseline * 0.8, value)))
        }
        
        return points
    }
}
class AdvancedFoodDatabase: ObservableObject {
    static let shared = AdvancedFoodDatabase()
    
    let mexicanFoods: [String: Food] = [
        // ✅ VEGETALES (incluyendo los nuevos)
        "ensalada": Food(name: "ensalada", displayName: "Ensalada Verde", glycemicIndex: 15, fiberContent: 2.5, proteinContent: 1.5, carbContent: 4.0, fatContent: 0.2, category: .vegetables),
        "nopales": Food(name: "nopales", displayName: "Nopales", glycemicIndex: 7, fiberContent: 3.7, proteinContent: 1.7, carbContent: 2.9, fatContent: 0.1, category: .vegetables),
        "quelites": Food(name: "quelites", displayName: "Quelites", glycemicIndex: 15, fiberContent: 4.2, proteinContent: 2.8, carbContent: 3.1, fatContent: 0.3, category: .vegetables),
        "verdolagas": Food(name: "verdolagas", displayName: "Verdolagas", glycemicIndex: 12, fiberContent: 3.4, proteinContent: 2.0, carbContent: 2.5, fatContent: 0.4, category: .vegetables),
        
        // ✅ NUEVOS: Brócoli y Zanahoria
        "brocoli": Food(name: "brocoli", displayName: "Brócoli", glycemicIndex: 25, fiberContent: 5.1, proteinContent: 2.8, carbContent: 6.6, fatContent: 0.4, category: .vegetables),
        "zanahoria": Food(name: "zanahoria", displayName: "Zanahoria", glycemicIndex: 47, fiberContent: 2.8, proteinContent: 0.9, carbContent: 9.6, fatContent: 0.2, category: .vegetables),
        
        // ✅ VEGETALES ADICIONALES para mejor detección ML
        "coliflor": Food(name: "coliflor", displayName: "Coliflor", glycemicIndex: 35, fiberContent: 3.0, proteinContent: 1.9, carbContent: 5.0, fatContent: 0.3, category: .vegetables),
        "espinacas": Food(name: "espinacas", displayName: "Espinacas", glycemicIndex: 15, fiberContent: 2.2, proteinContent: 2.9, carbContent: 3.6, fatContent: 0.4, category: .vegetables),
        "tomate": Food(name: "tomate", displayName: "Tomate", glycemicIndex: 30, fiberContent: 1.2, proteinContent: 0.9, carbContent: 3.9, fatContent: 0.2, category: .vegetables),
        "lechuga": Food(name: "lechuga", displayName: "Lechuga", glycemicIndex: 10, fiberContent: 1.3, proteinContent: 1.4, carbContent: 2.9, fatContent: 0.2, category: .vegetables),
        
        // PROTEÍNAS
        "pollo": Food(name: "pollo", displayName: "Pechuga de Pollo", glycemicIndex: 0, fiberContent: 0, proteinContent: 31.0, carbContent: 0, fatContent: 3.6, category: .proteins),
        "pescado": Food(name: "pescado", displayName: "Pescado", glycemicIndex: 0, fiberContent: 0, proteinContent: 25.0, carbContent: 0, fatContent: 5.0, category: .proteins),
        "frijoles": Food(name: "frijoles", displayName: "Frijoles Negros", glycemicIndex: 38, fiberContent: 15.0, proteinContent: 21.6, carbContent: 63.0, fatContent: 1.4, category: .proteins),
        "lentejas": Food(name: "lentejas", displayName: "Lentejas", glycemicIndex: 32, fiberContent: 11.5, proteinContent: 18.0, carbContent: 40.0, fatContent: 0.8, category: .proteins),
        "huevos": Food(name: "huevos", displayName: "Huevos", glycemicIndex: 0, fiberContent: 0, proteinContent: 13.0, carbContent: 0.6, fatContent: 11.0, category: .proteins),
        
        // CARBOHIDRATOS
        "arroz": Food(name: "arroz", displayName: "Arroz Blanco", glycemicIndex: 73, fiberContent: 0.4, proteinContent: 2.7, carbContent: 28.0, fatContent: 0.3, category: .carbohydrates),
        "arroz_integral": Food(name: "arroz_integral", displayName: "Arroz Integral", glycemicIndex: 68, fiberContent: 1.8, proteinContent: 2.6, carbContent: 23.0, fatContent: 0.9, category: .carbohydrates),
        "tortilla": Food(name: "tortilla", displayName: "Tortilla de Maíz", glycemicIndex: 52, fiberContent: 6.8, proteinContent: 8.1, carbContent: 46.4, fatContent: 4.5, category: .carbohydrates),
        "pasta": Food(name: "pasta", displayName: "Pasta", glycemicIndex: 71, fiberContent: 1.8, proteinContent: 5.0, carbContent: 25.0, fatContent: 0.9, category: .carbohydrates),
        "pan": Food(name: "pan", displayName: "Pan de Caja", glycemicIndex: 75, fiberContent: 2.7, proteinContent: 9.0, carbContent: 49.0, fatContent: 3.2, category: .carbohydrates),
        "pan_integral": Food(name: "pan_integral", displayName: "Pan Integral", glycemicIndex: 51, fiberContent: 7.0, proteinContent: 13.0, carbContent: 43.0, fatContent: 4.2, category: .carbohydrates),
        
        // FRUTAS
        "manzana": Food(name: "manzana", displayName: "Manzana", glycemicIndex: 36, fiberContent: 2.4, proteinContent: 0.3, carbContent: 14.0, fatContent: 0.2, category: .fruits),
        "platano": Food(name: "platano", displayName: "Plátano", glycemicIndex: 51, fiberContent: 2.6, proteinContent: 1.1, carbContent: 23.0, fatContent: 0.3, category: .fruits),
        "naranja": Food(name: "naranja", displayName: "Naranja", glycemicIndex: 43, fiberContent: 3.1, proteinContent: 0.9, carbContent: 12.0, fatContent: 0.1, category: .fruits),
        
        // GRASAS
        "aguacate": Food(name: "aguacate", displayName: "Aguacate", glycemicIndex: 15, fiberContent: 6.7, proteinContent: 2.0, carbContent: 8.5, fatContent: 14.7, category: .fats),
        "nueces": Food(name: "nueces", displayName: "Nueces", glycemicIndex: 15, fiberContent: 6.7, proteinContent: 15.2, carbContent: 13.7, fatContent: 65.2, category: .fats)
    ]
    
    func searchFoods(query: String) -> [Food] {
        return mexicanFoods.values.filter {
            $0.displayName.lowercased().contains(query.lowercased()) ||
            $0.name.lowercased().contains(query.lowercased())
        }.sorted { $0.displayName < $1.displayName }
    }
    
    func getAllFoodsByCategory() -> [Food.FoodCategory: [Food]] {
        var categorizedFoods: [Food.FoodCategory: [Food]] = [:]
        
        for category in Food.FoodCategory.allCases {
            categorizedFoods[category] = mexicanFoods.values.filter { $0.category == category }
                .sorted { $0.displayName < $1.displayName }
        }
        
        return categorizedFoods
    }
    
    func getRandomMealCombination() -> [Food] {
        let vegetables = mexicanFoods.values.filter { $0.category == .vegetables }
        let proteins = mexicanFoods.values.filter { $0.category == .proteins }
        let carbs = mexicanFoods.values.filter { $0.category == .carbohydrates }
        
        var meal: [Food] = []
        
        if let vegetable = vegetables.randomElement() {
            meal.append(vegetable)
        }
        if let protein = proteins.randomElement() {
            meal.append(protein)
        }
        if let carb = carbs.randomElement() {
            meal.append(carb)
        }
        
        return meal
    }
}



class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCameraAvailable = true
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(UIImage(systemName: "photo"))
        }
    }
}

class SimpleDataManager: ObservableObject {
    static let shared = SimpleDataManager()
    
    @Published var savedMeals: [SavedMeal] = []
    @Published var glucoseReadings: [GlucoseReading] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        let sampleReadings = [
            GlucoseReading(value: 95, timestamp: Date().addingTimeInterval(-7200), context: "Ayuno", mealId: UUID()),
            GlucoseReading(value: 148, timestamp: Date().addingTimeInterval(-5400), context: "Post-comida", mealId: UUID()),
            GlucoseReading(value: 112, timestamp: Date().addingTimeInterval(-3600), context: "2h post-comida", mealId: UUID()),
            GlucoseReading(value: 102, timestamp: Date().addingTimeInterval(-1800), context: "Actual", mealId: UUID())
        ]
        
        self.glucoseReadings = sampleReadings
    }
    
    func saveMeal(_ meal: SavedMeal) {
        savedMeals.append(meal)
    }
    
    // ✅ FUNCIÓN QUE FALTABA
    func addGlucoseReading(_ reading: GlucoseReading) {
        glucoseReadings.insert(reading, at: 0)
        if glucoseReadings.count > 100 {
            glucoseReadings = Array(glucoseReadings.prefix(100))
        }
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permisos de notificación concedidos")
            }
        }
    }
    
    func scheduleGlucoseReminders() {
        let center = UNUserNotificationCenter.current()
        
        let content30 = UNMutableNotificationContent()
        content30.title = "Recordatorio FirstBite"
        content30.body = "¿Cómo te sientes? Considera medir tu glucosa"
        content30.sound = .default
        
        let trigger30 = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        let request30 = UNNotificationRequest(identifier: "glucose_30min", content: content30, trigger: trigger30)
        
        let content60 = UNMutableNotificationContent()
        content60.title = "Recordatorio FirstBite"
        content60.body = "Hora de medir tu glucosa - 1 hora después de comer"
        content60.sound = .default
        
        let trigger60 = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: false)
        let request60 = UNNotificationRequest(identifier: "glucose_60min", content: content60, trigger: trigger60)
        
        let content120 = UNMutableNotificationContent()
        content120.title = "Recordatorio FirstBite"
        content120.body = "Última medición - 2 horas después de comer"
        content120.sound = .default
        
        let trigger120 = UNTimeIntervalNotificationTrigger(timeInterval: 120 * 60, repeats: false)
        let request120 = UNNotificationRequest(identifier: "glucose_120min", content: content120, trigger: trigger120)
        
        center.add(request30)
        center.add(request60)
        center.add(request120)
    }
}
