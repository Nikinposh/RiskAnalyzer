//
//  RiskAnalyzerApp.swift
//  RiskAnalyzer
//
//  Created by Никита Поляков on 11.12.2025.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Модель данных
struct RiskItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var probability: Double
    var lossMin: Double
    var lossMax: Double
    var severity: Double
    
    var riskValue: Double { probability * severity }
    var expectedLoss: Double { probability * (lossMin + lossMax) / 2 }
    
    var riskLevel: String {
        if riskValue >= 8 { return "КРИТИЧЕСКИЙ" }
        else if riskValue >= 6 { return "ВЫСОКИЙ" }
        else if riskValue >= 4 { return "СРЕДНИЙ" }
        else if riskValue >= 2 { return "НИЗКИЙ" }
        else { return "МИНИМАЛЬНЫЙ" }
    }
    
    var riskColor: Color {
        if riskValue >= 8 { return .red }
        else if riskValue >= 6 { return .orange }
        else if riskValue >= 4 { return .yellow }
        else if riskValue >= 2 { return .green }
        else { return .blue }
    }
}

// MARK: - Главное приложение
struct ContentView: View {
    @State private var items: [RiskItem] = []
    @State private var selectedItem: RiskItem?
    @State private var newName = ""
    @State private var newCategory = "Конфиденциальность"
    @State private var newProbability = 0.3
    @State private var newLossMin = "1000000"
    @State private var newLossMax = "5000000"
    @State private var newSeverity = 7.0
    @State private var status = "Готов"
    @State private var showingExportOptions = false
    @State private var exportType = "CSV"
    
    let categories = ["Конфиденциальность", "Производство", "Доступность", "Учет", "Финансы", "Репутация", "Коммуникации"]
    
    var body: some View {
        NavigationView {
            // Левая панель
            VStack {
                Text("Активы")
                    .font(.headline)
                    .padding(.top)
                
                List(items) { item in
                    HStack {
                        Circle()
                            .fill(item.riskColor)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(item.riskLevel)
                                .font(.caption)
                                .foregroundColor(item.riskColor)
                                .fontWeight(.bold)
                            Text("₽\(formatCurrency(item.expectedLoss))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectItem(item)
                    }
                    .background(
                        selectedItem?.id == item.id ?
                        Color.blue.opacity(0.1) : Color.clear
                    )
                }
                .listStyle(PlainListStyle())
                
                Divider()
                
                VStack(spacing: 8) {
                    Text("Статистика")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Всего активов: \(items.count)")
                            Text("Суммарный риск: ₽\(formatCurrency(totalRiskValue))")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                Button("Загрузить тестовые данные") {
                    loadSampleData()
                }
                .padding(.bottom)
            }
            .frame(width: 350)
            
            // Правая панель
            VStack(spacing: 20) {
                // Заголовок
                VStack {
                    Text("АО Концерн ЦНИИ Электроприбор")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Анализатор рисков информационной безопасности")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                Divider()
                
                // Детали выбранного элемента
                if let item = selectedItem {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Детали актива")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("Удалить") {
                                deleteSelectedItem()
                            }
                            .foregroundColor(.red)
                        }
                        
                        DetailRow(title: "Название:", value: item.name)
                        DetailRow(title: "Категория:", value: item.category)
                        DetailRow(title: "Вероятность:", value: String(format: "%.1f%%", item.probability * 100))
                        DetailRow(title: "Ущерб (мин):", value: "₽\(formatCurrency(item.lossMin))")
                        DetailRow(title: "Ущерб (макс):", value: "₽\(formatCurrency(item.lossMax))")
                        DetailRow(title: "Тяжесть:", value: String(format: "%.1f/10", item.severity))
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Уровень риска:")
                                    .font(.headline)
                                Text(item.riskLevel)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(item.riskColor)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Ожидаемый ущерб:")
                                    .font(.headline)
                                Text("₽\(formatCurrency(item.expectedLoss))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 50))
                            .foregroundColor(.blue.opacity(0.5))
                        
                        Text("Выберите актив из списка")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Или добавьте новый актив")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Форма добавления/редактирования
                VStack(spacing: 16) {
                    Text(formTitle)
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Название актива", text: $newName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Категория", selection: $newCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            VStack(alignment: .leading) {
                                Text("Вероятность: \(newProbability * 100, specifier: "%.1f")%")
                                Slider(value: $newProbability, in: 0...1, step: 0.05)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Мин. ущерб (₽):")
                                TextField("0", text: $newLossMin)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 150)
                            }
                            
                            HStack {
                                Text("Макс. ущерб (₽):")
                                TextField("0", text: $newLossMax)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 150)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Тяжесть: \(newSeverity, specifier: "%.1f")/10")
                                Slider(value: $newSeverity, in: 1...10, step: 0.5)
                            }
                        }
                    }
                    
                    HStack {
                        if selectedItem != nil {
                            Button("Обновить") {
                                updateSelectedItem()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Отмена") {
                                clearForm()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        Button(selectedItem == nil ? "Добавить" : "Создать копию") {
                            if selectedItem == nil {
                                addNewItem()
                            } else {
                                createCopy()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newName.isEmpty || !isValidCurrency(newLossMin) || !isValidCurrency(newLossMax))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Divider()
                
                // Панель экспорта
                VStack(spacing: 12) {
                    HStack {
                        Picker("Формат отчета:", selection: $exportType) {
                            Text("CSV").tag("CSV")
                            Text("TXT").tag("TXT")
                            Text("JSON").tag("JSON")
                        }
                        .frame(width: 200)
                        
                        Button("Создать отчет") {
                            showingExportOptions = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Button("Экспорт данных") {
                            exportData()
                        }
                        
                        Button("Сохранить в файл") {
                            saveToFile()
                        }
                        
                        Button("Печать отчета") {
                            printReport()
                        }
                    }
                }
                
                // Статус
                Text(status)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 600)
        }
        .frame(minWidth: 1000, minHeight: 700)
        .confirmationDialog("Выберите действие", isPresented: $showingExportOptions) {
            Button("Показать в консоли") {
                showReportInConsole()
            }
            Button("Скопировать в буфер") {
                copyToClipboard()
            }
            Button("Отмена", role: .cancel) { }
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    // MARK: - Вычисляемые свойства
    
    private var totalRiskValue: Double {
        items.reduce(0) { $0 + $1.expectedLoss }
    }
    
    private var formTitle: String {
        if selectedItem == nil {
            return "Добавить новый актив"
        } else {
            return "Редактировать актив"
        }
    }
    
    // MARK: - Методы
    
    private func selectItem(_ item: RiskItem) {
        selectedItem = item
        newName = item.name
        newCategory = item.category
        newProbability = item.probability
        newLossMin = formatCurrency(item.lossMin)
        newLossMax = formatCurrency(item.lossMax)
        newSeverity = item.severity
        status = "Выбран: \(item.name)"
    }
    
    private func addNewItem() {
        guard !newName.isEmpty,
              let lossMin = parseCurrency(newLossMin),
              let lossMax = parseCurrency(newLossMax) else {
            status = "Ошибка: проверьте введенные данные"
            return
        }
        
        let newItem = RiskItem(
            name: newName,
            category: newCategory,
            probability: newProbability,
            lossMin: lossMin,
            lossMax: lossMax,
            severity: newSeverity
        )
        
        items.append(newItem)
        selectedItem = newItem
        status = "Добавлен: \(newName)"
    }
    
    private func createCopy() {
        guard !newName.isEmpty,
              let lossMin = parseCurrency(newLossMin),
              let lossMax = parseCurrency(newLossMax) else {
            status = "Ошибка: проверьте введенные данные"
            return
        }
        
        let copyItem = RiskItem(
            name: newName,
            category: newCategory,
            probability: newProbability,
            lossMin: lossMin,
            lossMax: lossMax,
            severity: newSeverity
        )
        
        items.append(copyItem)
        selectedItem = copyItem
        status = "Создана копия: \(newName)"
    }
    
    private func updateSelectedItem() {
        guard let selected = selectedItem,
              let index = items.firstIndex(where: { $0.id == selected.id }) else {
            status = "Ошибка: элемент не найден"
            return
        }
        
        guard !newName.isEmpty,
              let lossMin = parseCurrency(newLossMin),
              let lossMax = parseCurrency(newLossMax) else {
            status = "Ошибка: проверьте введенные данные"
            return
        }
        
        let updatedItem = RiskItem(
            id: selected.id,
            name: newName,
            category: newCategory,
            probability: newProbability,
            lossMin: lossMin,
            lossMax: lossMax,
            severity: newSeverity
        )
        
        items[index] = updatedItem
        selectedItem = updatedItem
        status = "Обновлен: \(newName)"
    }
    
    private func deleteSelectedItem() {
        guard let selected = selectedItem,
              let index = items.firstIndex(where: { $0.id == selected.id }) else { return }
        
        let deletedName = items[index].name
        items.remove(at: index)
        
        if !items.isEmpty {
            selectedItem = items[min(index, items.count - 1)]
        } else {
            selectedItem = nil
            clearForm()
        }
        
        status = "Удален: \(deletedName)"
    }
    
    private func clearForm() {
        newName = ""
        newCategory = "Конфиденциальность"
        newProbability = 0.3
        newLossMin = "1000000"
        newLossMax = "5000000"
        newSeverity = 7.0
        selectedItem = nil
        status = "Форма очищена"
    }
    
    private func loadSampleData() {
        items = [
            RiskItem(name: "Windchill PDM", category: "Конфиденциальность",
                    probability: 0.25, lossMin: 50000000, lossMax: 100000000, severity: 9.5),
            RiskItem(name: "ТПП Firebird", category: "Производство",
                    probability: 0.20, lossMin: 30000000, lossMax: 70000000, severity: 8.5),
            RiskItem(name: "VPN шлюз", category: "Доступность",
                    probability: 0.30, lossMin: 20000000, lossMax: 50000000, severity: 9.0),
            RiskItem(name: "1C:ERP", category: "Учет",
                    probability: 0.15, lossMin: 5000000, lossMax: 15000000, severity: 8.0),
            RiskItem(name: "Корпоративная почта", category: "Коммуникации",
                    probability: 0.40, lossMin: 1000000, lossMax: 3000000, severity: 7.5)
        ]
        status = "Загружено \(items.count) активов"
        
        if let firstItem = items.first {
            selectItem(firstItem)
        }
    }
    
    // MARK: - Форматирование и парсинг
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func parseCurrency(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned)
    }
    
    private func isValidCurrency(_ text: String) -> Bool {
        return parseCurrency(text) != nil
    }
    
    // MARK: - Экспорт и отчеты
    
    private func generateReport() -> String {
        switch exportType {
        case "CSV":
            return generateCSV()
        case "JSON":
            return generateJSON()
        default:
            return generateTXT()
        }
    }
    
    private func generateCSV() -> String {
        var csv = "Актив;Категория;Вероятность;Ущерб мин;Ущерб макс;Серьезность;Уровень риска;Ожидаемый ущерб\n"
        
        for item in items {
            csv += "\(item.name);\(item.category);\(item.probability);"
            csv += "\(item.lossMin);\(item.lossMax);\(item.severity);"
            csv += "\(item.riskLevel);\(item.expectedLoss)\n"
        }
        
        return csv
    }
    
    private func generateTXT() -> String {
        var report = String(repeating: "=", count: 50) + "\n"
        report += "ОТЧЕТ ПО АНАЛИЗУ РИСКОВ ИБ\n"
        report += "АО Концерн ЦНИИ Электроприбор\n"
        report += "Дата: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))\n"
        report += String(repeating: "=", count: 50) + "\n\n"
        
        report += "Всего активов: \(items.count)\n"
        report += "Суммарный ожидаемый ущерб: ₽\(formatCurrency(totalRiskValue))\n\n"
        
        report += "ДЕТАЛЬНЫЙ СПИСОК АКТИВОВ:\n"
        report += String(repeating: "-", count: 50) + "\n"
        
        for (index, item) in items.enumerated() {
            report += "\(index + 1). \(item.name) [\(item.category)]\n"
            report += "   Вероятность: \(item.probability * 100)%\n"
            report += "   Ущерб: от ₽\(formatCurrency(item.lossMin)) до ₽\(formatCurrency(item.lossMax))\n"
            report += "   Тяжесть: \(item.severity)/10\n"
            report += "   Уровень риска: \(item.riskLevel)\n"
            report += "   Ожидаемый ущерб: ₽\(formatCurrency(item.expectedLoss))\n\n"
        }
        
        return report
    }
    
    private func generateJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(items)
            return String(data: data, encoding: .utf8) ?? "Ошибка кодирования JSON"
        } catch {
            return "Ошибка: \(error.localizedDescription)"
        }
    }
    
    private func showReportInConsole() {
        let report = generateReport()
        print(report)
        status = "Отчет выведен в консоль (\(exportType))"
    }
    
    private func copyToClipboard() {
        let report = generateReport()
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report, forType: .string)
        #endif
        status = "Отчет скопирован в буфер (\(exportType))"
    }
    
    private func exportData() {
        let report = generateReport()
        let panel = NSSavePanel()
        panel.title = "Сохранить отчет"
        
        switch exportType {
        case "CSV":
            panel.nameFieldStringValue = "отчет_рисков.csv"
            panel.allowedContentTypes = [UTType.commaSeparatedText]
        case "JSON":
            panel.nameFieldStringValue = "отчет_рисков.json"
            panel.allowedContentTypes = [UTType.json]
        default:
            panel.nameFieldStringValue = "отчет_рисков.txt"
            panel.allowedContentTypes = [UTType.plainText]
        }
        
        panel.begin { response in
            DispatchQueue.main.async {
                if response == .OK, let url = panel.url {
                    do {
                        try report.write(to: url, atomically: true, encoding: .utf8)
                        self.status = "Отчет сохранен: \(url.lastPathComponent)"
                    } catch {
                        self.status = "Ошибка сохранения: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func saveToFile() {
        let panel = NSSavePanel()
        panel.title = "Сохранить данные"
        panel.nameFieldStringValue = "данные_рисков.json"
        panel.allowedContentTypes = [UTType.json]
        
        panel.begin { response in
            DispatchQueue.main.async {
                if response == .OK, let url = panel.url {
                    do {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let data = try encoder.encode(self.items)
                        try data.write(to: url)
                        self.status = "Данные сохранены: \(url.lastPathComponent)"
                    } catch {
                        self.status = "Ошибка сохранения: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func printReport() {
        let report = generateTXT()
        print("=== НАЧАЛО ПЕЧАТИ ===\n\(report)\n=== КОНЕЦ ПЕЧАТИ ===")
        status = "Отчет готов к печати (см. консоль)"
    }
}

// MARK: - Вспомогательные компоненты

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
