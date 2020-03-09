//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOptions: Int {
    case firstName
    case lastName
}

class StudentController {
    
    //private(set) is a get only - not writable
    private var students: [Student] = []
    
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent)
        
        bgQueue.async {
            // find students.json file path
                //when accessing something within the class within a closure you need to use "self."
            guard let url = self.persistentFileURL, FileManager.default.fileExists(atPath: url.path)  else {
                completion(nil, NSError())
                return
            }
            
            // read data from file into memory
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                // convert JSON data into Swift objects
                let students = try decoder.decode([Student].self, from: data)
                 // deliver the Swift objects to the students array
                self.students = students
                // signal th view controller it should reload it's table (in the viewcontroller file
                completion(students, nil)
                
            } catch {
                NSLog("Error loading student data: \(error)")
                completion(nil, error)
        }
     }
   }
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping([Student]) -> Void) {
        var updatedStudents: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudents = students.filter { $0.course == "iOS" }
        case .Web:
            updatedStudents = students.filter { $0.course == "Web" }
        case .UX:
            updatedStudents = students.filter { $0.course == "UX" }
        default:
            updatedStudents = students
        }
        
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName }
        }
        
        completion(updatedStudents) 
    }
}
