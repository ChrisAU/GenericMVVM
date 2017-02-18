//: Simple MVVM example using generics (no bindings)

import UIKit
import PlaygroundSupport

//: Protocol Definitions
protocol Model { }

protocol ViewModel {
    associatedtype T: Model
    init(model: T)
}

protocol View {
    associatedtype T: ViewModel
    init(viewModel: T)
}

//: Model Implementation
struct Person: Model {
    let title: String
    let firstName: String
    let lastName: String
    
    let address: String
    let city: String
    let postcode: String
    let country: String
}

//: View Model Implementation
struct PersonViewModel: ViewModel {
    typealias T = Person
    private let model: T
    
    init(model: T) {
        self.model = model
    }
    
    var name: String {
        return "\(model.title) \(model.firstName) \(model.lastName)"
    }
    
    var nameHeading: String {
        return "Name"
    }
    
    var address: String {
        return "\(model.address)\n\(model.city)\n\(model.postcode)\n\(model.country)"
    }
    
    var addressHeading: String {
        return "Address"
    }

    var title: String {
        return "Person Details"
    }
}

//: View Implementation
let padding: CGFloat = 20

final class PersonView: UIView, View {
    typealias T = PersonViewModel
    private let viewModel: T
    
    // This logic should be moved to a styling file
    private static func makeAttributedHeading(_ heading: String, text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: "\(heading):\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)])
        attr.append(NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]))
        return attr.copy() as! NSAttributedString
    }
    
    private static func makeLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private let nameLabel: UILabel =  PersonView.makeLabel()
    private let addressLabel: UILabel = PersonView.makeLabel()
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        nameLabel.attributedText = PersonView.makeAttributedHeading(viewModel.nameHeading, text: viewModel.name)
        
        addressLabel.attributedText = PersonView.makeAttributedHeading(viewModel.addressHeading, text: viewModel.address)
        
        [nameLabel, addressLabel].forEach(addSubview)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor),
            
            addressLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            addressLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: padding),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//: ViewController Implementation
final class PersonViewController: UIViewController, View {
    typealias T = PersonViewModel
    private let personView: PersonView
    
    init(viewModel: T) {
        self.personView = PersonView(viewModel: viewModel)
        self.personView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        view.addSubview(personView)
        
        title = viewModel.title
        
        NSLayoutConstraint.activate([
            personView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            personView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
            personView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding),
            personView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//: Example PersonViewController embedded in a UINavigationController
let person = Person(title: "Mrs", firstName: "Theresa", lastName: "May", address: "8 Downing Street", city: "London", postcode: "SW1A 2AA", country: "United Kingdom")
let personViewModel = PersonViewModel(model: person)
let personViewController = PersonViewController(viewModel: personViewModel)
let navigationController = UINavigationController(rootViewController: personViewController)

personViewController.edgesForExtendedLayout = []
navigationController.view.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 480))

PlaygroundPage.current.liveView = navigationController.view
