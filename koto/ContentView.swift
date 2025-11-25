//
//  ContentView.swift
//  koto
//
//  Created by Sahiba on 25/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @State private var newTitle: String = ""

    private var todoItems: [Item] {
        items.filter { !$0.isCompleted }
    }

    private var accomplishedItems: [Item] {
        items.filter(\.isCompleted)
    }

    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 16) {
                    addTodoField

                    todoList
                }
                .padding()
                .navigationTitle("koto")
            }
            .tabItem {
                Label("Todo", systemImage: "list.bullet.circle")
            }

            NavigationStack {
                accomplishedList
                    .padding(.top, 16)
                    .navigationTitle("Accomplished")
            }
            .tabItem {
                Label("Accomplished", systemImage: "checkmark.circle")
            }
        }
    }

    private var addTodoField: some View {
        HStack(spacing: 12) {
            TextField("Add a todo", text: $newTitle, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addItem)

            Button(action: addItem) {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.kotoAccent)
                    )
                    .accessibilityLabel("Add todo")
            }
            .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.plain)
        }
    }

    private var todoList: some View {
        List {
            ForEach(todoItems) { item in
                TodoRow(item: item, toggle: toggleCompletion)
                    .swipeActions {
                        Button(role: .destructive) {
                            delete(items: [item])
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete { offsets in
                let targets = offsets.map { todoItems[$0] }
                delete(items: targets)
            }
        }
        .listStyle(.plain)
    }

    private var accomplishedList: some View {
        List {
            ForEach(accomplishedItems) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item.title)
                        .foregroundStyle(.secondary)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        toggleCompletion(item)
                    } label: {
                        Label("Move to Todo", systemImage: "arrow.uturn.backward.circle")
                    }

                    Button(role: .destructive) {
                        delete(items: [item])
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                let targets = offsets.map { accomplishedItems[$0] }
                delete(items: targets)
            }
        }
        .listStyle(.plain)
    }

    private func addItem() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation {
            let newItem = Item(title: trimmed)
            modelContext.insert(newItem)
            newTitle = ""
        }
    }

    private func toggleCompletion(_ item: Item) {
        withAnimation {
            item.isCompleted.toggle()
        }
    }

    private func delete(items: [Item]) {
        withAnimation {
            items.forEach(modelContext.delete)
        }
    }
}

private struct TodoRow: View {
    @Bindable var item: Item
    let toggle: (Item) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                toggle(item)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .secondary)
                    .imageScale(.large)
                    .accessibilityLabel(item.isCompleted ? "Mark as todo" : "Mark as done")
            }

            Text(item.title)
        }
        .buttonStyle(.plain)
    }
}

private extension Color {
    static let kotoAccent = Color(red: 1.0, green: 189/255, blue: 74/255)
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
