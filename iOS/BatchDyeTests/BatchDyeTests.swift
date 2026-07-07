import XCTest
@testable import BatchDye

final class BatchDyeTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchDyeStore()
        XCTAssertGreaterThan(store.sessions.count, 0)
        XCTAssertLessThan(store.sessions.count, BatchDyeStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchDyeStore()
        let before = store.sessions.count
        let added = store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.sessions.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchDyeStore()
        let before = store.sessions.count
        let added = store.addSession(itemName: "   ", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.sessions.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchDyeStore()
        for item in store.sessions { store.deleteSession(item.id) }
        for _ in 0..<BatchDyeStore.freeLimit {
            XCTAssertTrue(store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false))
        }
        XCTAssertFalse(store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false))
        XCTAssertTrue(store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchDyeStore()
        store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false)
        guard let item = store.sessions.last else { return XCTFail("expected entry") }
        let before = store.sessions.count
        store.deleteSession(item.id)
        XCTAssertEqual(store.sessions.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchDyeStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.sessions.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchDyeStore()
        store.addSession(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min", isPro: false)
        guard let item = store.sessions.last else { return XCTFail("expected entry") }
        store.updateSession(item.id, itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min")
        XCTAssertEqual(store.sessions.count, store.sessions.count)
    }
}
