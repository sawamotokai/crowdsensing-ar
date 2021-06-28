//
//  RoutingMapViewController.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-23.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class RoutingMapViewController: UIViewController, MGLMapViewDelegate {
    var mapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var route: Route?
//    var task: Task?
    var assignment: Assignment?
    var routeController: RouteController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
        addToggleButton()
        // Converts point where user did a long press to map coordinates
        let lat: Double? = assignment?.task.trashbin.location.lat
        let lng: Double? = assignment?.task.trashbin.location.lng
        
        if lng != nil && lat != nil {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            annotation.title = "Reward"
            annotation.subtitle = "Tap to navigate"
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: false, completionHandler: nil)
        } else {
            print("task is not set")
            return
        }
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
         
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
         
        if let origin = mapView.userLocation?.coordinate {
        // Calculate the route from the user's location to the set destination
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
    
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Reward")
        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first, let strongSelf = self else {
                        return
                    }
                strongSelf.route = route
                strongSelf.routeOptions = routeOptions
                
                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)
                
                // Show destination waypoint on the map
//                strongSelf.mapView.showWaypoints(on: route)
                
                // Display callout view on destination annotation
                if let annotation = strongSelf.mapView.annotations?.first as? MGLPointAnnotation {
                    annotation.title = "Start navigation"
                    strongSelf.mapView.selectAnnotation(annotation, animated: true, completionHandler: nil)
                }
            }
        }
    }
    
    func drawRoute(route: Route) {
        guard let routeShape = route.shape, routeShape.coordinates.count > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = routeShape.coordinates
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
         
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
             
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
             
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
     
    // Present the navigation view controller when the callout is selected
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let lat: Double? = assignment?.task.trashbin.location.lat
        let lng: Double? = assignment?.task.trashbin.location.lng
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        if let origin = mapView.userLocation?.coordinate {
            // Calculate the route from the user's location to the set destination
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
            return
        }
        
//        calculateRoute(from: origin, to: goal)
        guard let route = route, let routeOptions = routeOptions else {
            return
        }
        DispatchQueue.main.async {
            let navigationViewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: routeOptions)
//            navigationViewController.navigationService.routeProgress.
            navigationViewController.modalPresentationStyle = .fullScreen
            self.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    @objc
    func startAR() {
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "ar_vc") as? ARViewController else {
                return
            }
            vc.assignment = self.assignment
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addToggleButton() {
        let button = UIButton(type: .system)
        button.setTitle("Start AR", for: .normal)
        button.isSelected = true
        button.sizeToFit()
        button.center.x = self.view.center.x
        button.frame = CGRect(origin: CGPoint(x: button.frame.origin.x, y: self.view.frame.size.height - button.frame.size.height - 5), size: button.frame.size)
        button.addTarget(self, action: #selector(startAR), for: .touchUpInside)
        self.view.addSubview(button)
         
        if #available(iOS 11.0, *) {
            let safeArea = view.safeAreaLayoutGuide
            button.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -5),
                button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
            ]
             
            NSLayoutConstraint.activate(constraints)
        } else {
            button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
    }
}



extension RoutingMapViewController: NavigationViewControllerDelegate {
    // Show an alert when arriving at the waypoint and wait until the user to start next leg.
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        print("inside")
        let isFinalLeg = navigationViewController.navigationService.routeProgress.isFinalLeg
        if isFinalLeg {
            print("ARRIVED!!!!!!!!!!!!!!!!!!!")
            DispatchQueue.main.async {
                guard let vc = self.storyboard?.instantiateViewController(identifier: "ar_vc") as? ARViewController else {
                    return
                }
                vc.assignment = self.assignment
                self.navigationController!.pushViewController(vc, animated: true)
            }
            return true
        }
        return false
    }
 
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        dismiss(animated: true, completion: nil)
    }
}
