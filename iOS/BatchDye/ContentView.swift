import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SessionListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BDTheme.accent)
    }
}

struct SessionListView: View {
    @EnvironmentObject private var store: BatchDyeStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Session?

    var body: some View {
        NavigationStack {
            ZStack {
                BDTheme.backdrop.ignoresSafeArea()
                if store.sessions.isEmpty {
                    ContentUnavailableView("No Sessions Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.sessions) { item in
                            SessionRow(item: item)
                                .listRowBackground(BDTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteSession(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Dye")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addSessionButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                SessionFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                SessionFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct SessionRow: View {
    let item: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.itemName)
                .font(BDTheme.headlineFont)
                .foregroundStyle(BDTheme.ink)
            Text(String(describing: item.foldPattern))
                .font(.caption)
                .foregroundStyle(BDTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum SessionFormMode: Identifiable {
    case add
    case edit(Session)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct SessionFormView: View {
    @EnvironmentObject private var store: BatchDyeStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: SessionFormMode

    @State private var draftItemName: String = ""
    @State private var draftFoldPattern: String = ""
    @State private var draftColors: String = ""
    @State private var draftFabricPrep: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BDTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Item", text: $draftItemName)
                    .accessibilityIdentifier("itemNameField")
                Picker("Fold Pattern", selection: $draftFoldPattern) {
                    ForEach(BDFoldPatternOption.all, id: \.self) { Text($0) }
                }
                TextField("Dye Colors", text: $draftColors)
                    .accessibilityIdentifier("colorsField")
                TextField("Fabric Prep", text: $draftFabricPrep)
                    .accessibilityIdentifier("fabricPrepField")
                    }
                    .listRowBackground(BDTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("sessionSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftItemName = item.itemName
        draftFoldPattern = item.foldPattern
        draftColors = item.colors
        draftFabricPrep = item.fabricPrep
        } else {
        draftItemName = ""
        draftFoldPattern = ""
        draftColors = ""
        draftFabricPrep = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addSession(itemName: draftItemName, foldPattern: draftFoldPattern, colors: draftColors, fabricPrep: draftFabricPrep, isPro: purchases.isPro)
        case .edit(let item):
            store.updateSession(item.id, itemName: draftItemName, foldPattern: draftFoldPattern, colors: draftColors, fabricPrep: draftFabricPrep)
        }
        BDHaptics.success()
        dismiss()
    }
}
