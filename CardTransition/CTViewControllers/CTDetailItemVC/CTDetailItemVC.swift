//
//  CTDetailItemVC.swift
//  CardTransition
//
//  Created by Alberto Josue Gonzalez Juarez on 06/10/18.
//  Copyright © 2018 Alberto Josue Gonzalez Juarez. All rights reserved.
//

import UIKit
protocol CTDetailItemInteractivityDelegate: class {
  func shouldDragDownToDismiss()
}
class CTDetailItemVC: AnimatableStatusBarViewController {
  weak var interactivityDelegate: CTDetailItemInteractivityDelegate?
  var disabledAnimation = false
  @IBOutlet weak var cardContentView: CardContentView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var textView: UITextView!
  
  var cardViewModel: CardCollectionViewCellViewModel! {
    didSet {
      if self.cardContentView != nil {
        self.cardContentView.viewModel = cardViewModel
      }
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    scrollView.contentInsetAdjustmentBehavior = .never
    cardContentView.viewModel = cardViewModel
    cardContentView.fontState(isHighlighted: true)
    // Do any additional setup after loading the view.
  }
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.additionalSafeAreaInsets = .init(top: -view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var animatedStatusBarPrefersStatusBarHidden: Bool {
    return true
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
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
extension CTDetailItemVC: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let shouldScrollEnabled: Bool
    if self.scrollView.isTracking && scrollView.contentOffset.y < 0 {
      shouldScrollEnabled = false
      self.interactivityDelegate?.shouldDragDownToDismiss()
    } else {
      shouldScrollEnabled = true
    }
    
    // Update only on change
    if shouldScrollEnabled != scrollView.isScrollEnabled {
      scrollView.showsVerticalScrollIndicator = shouldScrollEnabled
      scrollView.isScrollEnabled = shouldScrollEnabled
    }
  }
}
