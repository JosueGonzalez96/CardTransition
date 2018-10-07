//
//  CTMainVC.swift
//  CardTransition
//
//  Created by Alberto Josue Gonzalez Juarez on 06/10/18.
//  Copyright © 2018 Alberto Josue Gonzalez Juarez. All rights reserved.
//

import UIKit

class CTMainVC: AnimatableStatusBarViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  enum Constant {
    static let horizontalInset: CGFloat = 20
  }
  lazy var models: [CardCollectionViewCellViewModel] = [
    CardCollectionViewCellViewModel(primaryHeader: "Primary", secondaryHeader: "Secondary", descriptionHeader: "Desc", image: #imageLiteral(resourceName: "monument-valley.png").resize(toWidth: UIScreen.main.bounds.size.width * (1/kHighlightedFactor))),
    CardCollectionViewCellViewModel(primaryHeader: "You won't believe this guy", secondaryHeader: "Something we want", descriptionHeader: "They have something we want which is not something we need.", image: #imageLiteral(resourceName: "monument-valley.png").resize(toWidth: UIScreen.main.bounds.size.width * (1/kHighlightedFactor))),
    CardCollectionViewCellViewModel(primaryHeader: "ALV", secondaryHeader: "Hey", descriptionHeader: "They have something we want which is not something we need.", image: #imageLiteral(resourceName: "monument-valley.png").resize(toWidth: UIScreen.main.bounds.size.width * (1/kHighlightedFactor)))
  ]
  private var transitionManager: CardToDetailTransitionManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.delaysContentTouches = false
    
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = 20
      layout.minimumInteritemSpacing = 0
      layout.sectionInset = .init(top: 20, left: 0, bottom: 64, right: 0)
    }
    
    collectionView.delegate = self
    collectionView.dataSource = self
    // Do any additional setup after loading the view.
  }
  override var animatedStatusBarPrefersStatusBarHidden: Bool {
    return false
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
extension CTMainVC: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! CTMainCell
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let cell = cell as! CTMainCell
    cell.cardContentView?.viewModel = models[indexPath.row]
  }
}
extension CTMainVC: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.size.width - 2 * Constant.horizontalInset
    let height: CGFloat = width * 1.3
    return CGSize(width: width , height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = storyboard!.instantiateViewController(withIdentifier: "CTDetailItemVC") as! CTDetailItemVC
    let ind = indexPath
    let cardModel = models[ind.item]
    let cell = collectionView.cellForItem(at: ind) as! CTMainCell
    
    // Freeze animation highlighted state (or else it will bounce back)
    cell.disabledAnimation = true
    cell.layer.removeAllAnimations()
    
    let currentCellFrame = cell.layer.presentation()!.frame
    let cardFrame = cell.superview!.convert(currentCellFrame, to: nil)
    
    // We maintain scale down image version on the detail page, including animation
    vc.cardViewModel = cardModel.scaledHighlightImageState()
    
    // Card's frame relative to UIWindow
    let frameWithoutTransform = { () -> CGRect in
      let center = cell.center
      let size = cell.bounds.size
      let r = CGRect(
        x: center.x - size.width / 2,
        y: center.y - size.height / 2,
        width: size.width,
        height: size.height
      )
      return cell.superview!.convert(r, to: nil)
    }()
    
    let params = (fromCardFrame: cardFrame, fromCardFrameWithoutTransform: frameWithoutTransform, viewModel: cardModel, fromCell: cell)
    self.transitionManager = CardToDetailTransitionManager(params)
    self.transitionManager.cardDetailViewController = vc
    vc.transitioningDelegate = transitionManager
    
    self.present(vc, animated: true, completion: {
      cell.isHidden = false
      
      // Unfreeze
      cell.disabledAnimation = false
    })
  }
}
