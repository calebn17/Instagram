//
//  Extensions.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation
import UIKit

extension UIView {
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        frame.origin.y + height
    }
    var left: CGFloat {
        frame.origin.x
    }
    var right: CGFloat {
        frame.origin.x + width
    }
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
}
extension Decodable {
    init?(with dictionary: [String: Any]) {
        //convert dictionary into json and storing in "data"
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {return nil}
        
        //decoding the json "data" into whatever Model type is specified (Self.self)
        guard let result = try? JSONDecoder().decode(Self.self, from: data) else {return nil}
        self = result
    }
}
extension Encodable {
    func asDictionary() -> [String: Any]? {
        
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return json
    }
}
