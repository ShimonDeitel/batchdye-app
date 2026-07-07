import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchDyeStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchdye_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchdye_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BDTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BDTheme.accent)
                                Text("Batch Dye Pro active")
                                    .foregroundStyle(BDTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BDTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BDTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BDTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BDTheme.card)

                    if purchases.isPro {
                        Section("Soda-Ash & Dye Ratio Calculator") {
                            Text("Calculate soda ash and dye ratios by fabric weight.")
                                .font(.caption)
                                .foregroundStyle(BDTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.fabricWeightOz)
                                        .foregroundStyle(BDTheme.ink)
                                    Spacer()
                                    Text(p.sodaAshCups)
                                        .font(.caption)
                                        .foregroundStyle(BDTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BDTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BDHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BDTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddSessionButton")
                    }
                    .listRowBackground(BDTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchdye-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchdye-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BDTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BDTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                SessionFormView(mode: .add)
            }
        }
    }
}
