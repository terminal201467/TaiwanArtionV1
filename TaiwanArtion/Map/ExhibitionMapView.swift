//
//  ExhibitionMapView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/21.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class ExhibitionMapView: UIView {
    
    private let viewModel = NearViewModel.shared
    
    let locationInterface = LocationInterface.shared

    private let locationQueue = DispatchQueue(label: "mapLocation", attributes: .concurrent)
    
    private let disposeBag = DisposeBag()
    
    var locatedNearSignal: Signal<Void> = Signal.just(())
    
    var locatedCurrentMyLocationSignal: Signal<Void> = Signal.just(())
    
    private let locateRecentExhibitionButton: UIButton = {
        let button = UIButton()
        button.setTitle("離我最近的展覽館", for: .normal)
        button.backgroundColor = .brownColor
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.roundCorners(cornerRadius: 12)
        return button
    }()
    
    let mapView: MKMapView = {
       let view = MKMapView()
        view.preferredConfiguration.elevationStyle = .flat
        view.showsUserLocation = true
        view.register(MapAnnocationView.self, forAnnotationViewWithReuseIdentifier: MapAnnocationView.reuseIdentifier)
        return view
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(named: "locationButton"), for: .normal)
        return button
    }()
    
    //CollectionView
    let locationContentCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(LocationContentCollectionViewCell.self, forCellWithReuseIdentifier: LocationContentCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setMapView()
        setLocationContentCollectionView()
        autoLayout()
        setButtonSubscribtion()
        setMapFeature()
        findAndStoreCenteredCellIndexPath()
        viewModel.output.outputExhibitionHall
            .asObservable()
            .subscribe(onNext: { [weak self] info in
                guard let self = self else { return }
                self.setContentStackIsHidden()
                self.locationContentCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func findAndStoreCenteredCellIndexPath() {
        let centerX = locationContentCollectionView.contentOffset.x + locationContentCollectionView.bounds.width / 2
        if let indexPath = locationContentCollectionView.indexPathForItem(at: CGPoint(x: centerX, y: locationContentCollectionView.bounds.height / 2)) {
            AppLogger.debug("indexPath:\(indexPath.row)", category: .map)
            self.mapView(self.mapView,
                         didSelect: self.mapView.dequeueReusableAnnotationView(withIdentifier: MapAnnocationView.reuseIdentifier, for: self.mapView.annotations[indexPath.row]))
        }
    }
    
    private func setLocationContentCollectionView() {
        locationContentCollectionView.delegate = self
        locationContentCollectionView.dataSource = self
    }
    
    private func setMapView() {
        mapView.delegate = self
    }
    
    func showCurrentLocation(by latitudinalMeters: Double, by longitudinalMeters: Double) {
        locationInterface.checkLocationAuthorization()
        let locationCoordinate = locationInterface.getCurrentLocation().coordinate
        let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        mapView.setRegion(region, animated: true)
    }
    
    private func autoLayout() {
        addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mapView.addSubview(locateRecentExhibitionButton)
        locateRecentExhibitionButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2.5)
        }
        
        mapView.addSubview(locationContentCollectionView)
        locationContentCollectionView.snp.makeConstraints { make in
            make.height.equalTo(130.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func locationButtonAutoLayoutWithContent() {
        locationContentCollectionView.isHidden = false
        
        mapView.addSubview(locationContentCollectionView)
        locationContentCollectionView.snp.makeConstraints { make in
            make.height.equalTo(130.0)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        mapView.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.bottom.equalTo(locationContentCollectionView.snp.top).offset(-16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(36.0)
            make.width.equalTo(36.0)
        }
    }
    
    private func locationButtonAutoLayoutWithoutContent() {
        locationContentCollectionView.isHidden = true
        mapView.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(36.0)
            make.width.equalTo(36.0)
        }
    }
    
    private func setContentStackIsHidden() {
        mapView.removeSubview(locationButton)
        viewModel.output.outputExhibitionHall.value.isEmpty ? self.locationButtonAutoLayoutWithoutContent() : self.locationButtonAutoLayoutWithContent()
    }
    
    private func setButtonSubscribtion() {
        locatedNearSignal = locateRecentExhibitionButton.rx.tap
            .asSignal(onErrorJustReturn: ())
        
        locatedCurrentMyLocationSignal = locationButton.rx.tap
            .asSignal(onErrorJustReturn: ())
    }
    
    private func setMapFeature() {
        //顯示現在位置＋周邊展覽館
        locatedNearSignal.emit(onNext: {
            self.showCurrentLocation(by: 5000, by: 5000)
            
            self.locationQueue.async {
                self.locationInterface.searchTheLocations(searchKeyword: "博物館") { mapItems in
                    for item in mapItems {
                        DispatchQueue.main.async {
                            let mapAnnotation = MapLocationPinAnnotation(coordinate: item.placemark.coordinate)
                            self.mapView.addAnnotation(mapAnnotation)
                        }
                    }
                    self.viewModel.input.inputNearExhibitionHall.accept(mapItems)
                }
                
                self.locationInterface.searchTheLocations(searchKeyword: "展覽館") { mapItems in
                    for item in mapItems {
                        DispatchQueue.main.async {
                            let mapAnnotation = MapLocationPinAnnotation(coordinate: item.placemark.coordinate)
                            self.mapView.addAnnotation(mapAnnotation)
                        }
                    }
                    self.viewModel.input.inputNearExhibitionHall.accept(mapItems)
                }
                
                self.locationInterface.searchTheLocations(searchKeyword: "藝文中心") { mapItems in
                    for item in mapItems {
                        DispatchQueue.main.async {
                            let mapAnnotation = MapLocationPinAnnotation(coordinate: item.placemark.coordinate)
                            self.mapView.addAnnotation(mapAnnotation)
                        }
                    }
                    self.viewModel.input.inputNearExhibitionHall.accept(mapItems)
                }
            }
            self.setContentStackIsHidden()
        })
        .disposed(by: disposeBag)
        
        //顯示現在位置
        locatedCurrentMyLocationSignal.emit(onNext: {
            self.showCurrentLocation(by: 1000, by: 1000)
            self.mapView.annotations.map { annotation in
                self.mapView.removeAnnotation(annotation)
            }
            self.locationButtonAutoLayoutWithoutContent()
        })
        .disposed(by: disposeBag)
        
        self.locationInterface.mapUpdateCenter = { centerRegion in
            AppLogger.debug("centerRegion:\((centerRegion))", category: .map)
            self.mapView.setRegion(centerRegion, animated: true)
        }
    }
}

//MARK: -NearViewCollectionViewDelegate
extension ExhibitionMapView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.outputExhibitionHall.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationContentCollectionViewCell.reuseIdentifier, for: indexPath) as! LocationContentCollectionViewCell
        cell.configure(hallInfo: viewModel.output.outputExhibitionHall.value[indexPath.row])
        cell.lookUpLocationSignal.emit(onNext: {
            self.mapView(self.mapView,
                         didSelect: self.mapView.dequeueReusableAnnotationView(withIdentifier: MapAnnocationView.reuseIdentifier, for:self.mapView.annotations[indexPath.row]))
        })
        .disposed(by: disposeBag)
        cell.lookUpExhibitionHallSignal.emit(onNext: {
            //推到展覽館頁面
            AppLogger.debug("indexPath.row:\(indexPath.row)", category: .map)
            AppLogger.debug("ExhibitionHall:\(self.viewModel.output.outputExhibitionHall.value[indexPath.row])", category: .map)
        })
        .disposed(by: disposeBag)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width - (16 * 2)
        let cellHeight = 130.0
        return .init(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        findAndStoreCenteredCellIndexPath()
    }
}

//MARK: -MapViewCollectionViewDelegate

extension ExhibitionMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapAnnotation = annotation as? MapLocationPinAnnotation else { return .none}
        let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MapAnnocationView.reuseIdentifier, for: annotation) as! MapAnnocationView
        viewModel.output.outputSelectedAnnotation
            .subscribe(onNext: { [weak dequeuedView] selectedAnnotation in
                dequeuedView?.configureMarkBackground(isSelected: selectedAnnotation.coordinate == annotation.coordinate)
            })
            .disposed(by: disposeBag)
        if let index = viewModel.output.outputMapItem.value.firstIndex(where: {$0.placemark.location?.coordinate == annotation.coordinate}) {
            dequeuedView.configure(number: index + 1)
            dequeuedView.configureMarkBackground(isSelected: false)
        }
        return dequeuedView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewModel.input.inputSelectedAnnotation.accept(view.annotation!)
        mapView.setCenter(view.annotation?.coordinate ?? mapView.userLocation.coordinate, animated: true)
        //點按之後CollectionView show 出該 資訊的Cell
    }
}
