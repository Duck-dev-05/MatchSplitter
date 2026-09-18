import SwiftUI

struct ExportReportView: View {
    @Environment(\.presentationMode) var presentationMode
    var group: Group
    
    @State private var selectedFormat = 0 // 0: CSV, 1: HTML
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    
    let formats = ["CSV", "HTML"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Options")) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(0..<formats.count, id: \.self) { index in
                            Text(formats[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(footer: Text("The report will include all expenses and settlements for \(group.name).")) {
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            Spacer()
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Generate Report")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Theme.primaryAccent)
                    .cornerRadius(10)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Export Report")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showShareSheet, content: {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            })
        }
    }
    
    private func exportData() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let url: URL?
            if selectedFormat == 0 {
                url = ReportGenerator.shared.generateCSV(for: group)
            } else {
                url = ReportGenerator.shared.generateHTML(for: group)
            }
            
            DispatchQueue.main.async {
                self.isExporting = false
                if let generatedURL = url {
                    self.exportURL = generatedURL
                    self.showShareSheet = true
                } else {
                    ErrorManager.shared.showError("Failed to generate report.")
                }
            }
        }
    }
}
