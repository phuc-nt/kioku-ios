import SwiftUI
import SwiftData

struct TestDataInsertionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isInserted = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Data Insertion")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This will create test entries for:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• 5 entries for 11th of past months (Aug, Jul, Jun, May, Apr)")
                Text("• 3 entries for 22nd of past months (Aug, Jul, Jun)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: insertTestData) {
                Text(isInserted ? "Test Data Inserted ✅" : "Insert Test Data")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(isInserted ? Color.green : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isInserted)
            
            if isInserted {
                Text("Test data has been successfully inserted!\nYou can now test historical notes by long pressing on 11th or 22nd in the calendar.")
                    .font(.caption)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
    }
    
    private func insertTestData() {
        // Entry content for 11th of past months
        let contents11th = [
            "August reflection: This month has been productive with many coding achievements. The summer heat is intense but manageable.",
            "July memories: Vacation time with family was wonderful. Visited the mountains and enjoyed the cooler weather there.",
            "June thoughts: Mid-year review shows good progress on personal goals. Starting to plan for the second half of the year.",
            "May musings: Spring is in full bloom. Garden is looking beautiful and I'm feeling energized by the longer days.",
            "April notes: Easter celebrations with loved ones. The weather is getting warmer and I'm enjoying outdoor activities again."
        ]
        
        // Entry content for 22nd of past months
        let contents22nd = [
            "Late August update: Preparing for the end of summer. Planning some final outdoor adventures before fall arrives.",
            "July wrap-up: Month is flying by. Balancing work projects with summer fun. Feeling grateful for this time.",
            "June milestone: Halfway through the year already! Time to assess goals and adjust plans for the remaining months."
        ]
        
        let calendar = Calendar.current
        let today = Date()
        
        // Function to create a date for a specific day in a past month
        func createDate(monthsBack: Int, day: Int) -> Date {
            let currentMonth = calendar.startOfMonth(for: today)
            let targetMonth = calendar.date(byAdding: .month, value: -monthsBack, to: currentMonth)!
            
            var components = calendar.dateComponents([.year, .month], from: targetMonth)
            components.day = day
            
            return calendar.date(from: components) ?? targetMonth
        }
        
        // Create entries for 11th of past months
        for (index, content) in contents11th.enumerated() {
            let date = createDate(monthsBack: index + 1, day: 11)
            let entry = Entry(content: content, date: date)
            modelContext.insert(entry)
        }
        
        // Create entries for 22nd of past months
        for (index, content) in contents22nd.enumerated() {
            let date = createDate(monthsBack: index + 1, day: 22)
            let entry = Entry(content: content, date: date)
            modelContext.insert(entry)
        }
        
        // Save changes
        do {
            try modelContext.save()
            isInserted = true
            print("✅ Test data inserted successfully!")
        } catch {
            print("❌ Failed to insert test data: \(error)")
        }
    }
}


#Preview {
    TestDataInsertionView()
        .environment(DataService.preview)
}