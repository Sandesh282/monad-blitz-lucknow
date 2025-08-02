import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newItem = ScoreEntity(context: viewContext)
            newItem.walletAddress = "0x\(String(format: "%040d", i))"
            newItem.totalScore = Int32(100 + i * 20)
            newItem.skillsScore = Int32(50 + i * 10)
            newItem.projectsScore = Int32(30 + i * 5)
            newItem.poapsScore = Int32(20 + i * 3)
            newItem.bonusScore = Int32(10 + i * 2)
            newItem.verificationDate = Date().addingTimeInterval(Double(-i * 86400))
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MoveMint")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
} 