//
//  PlaylistSelectorViewController.swift
//  4champ
//
//  Created by Aleksi Sitomaniemi on 13.3.2020.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SwiftUI

protocol PlaylistSelectorDisplayLogic: class {
  func displaySelector(viewModel: PlaylistSelector.PrepareSelection.ViewModel)
  func displayAppend(viewModel: PlaylistSelector.Append.ViewModel)
}

class PlaylistSelectorStore: ObservableObject, PlaylistSelectorDisplayLogic {
  var interactor: PlaylistSelectorBusinessLogic?
  var router: (NSObjectProtocol & PlaylistSelectorRoutingLogic & PlaylistSelectorDataPassing)?
  weak var hostingController: UIHostingController<PlaylistPickerView>?

  @Published var viewModel: PlaylistSelector.PrepareSelection.ViewModel

  init() {
    self.viewModel = PlaylistSelector.PrepareSelection.ViewModel(module: "<rnd>", currentPlaylistIndex: 0, playlistOptions: [], status: .unknown)
  }

  public static func buildPicker(module: MMD) -> UIHostingController<PlaylistPickerView> {
    let pls = PlaylistSelectorStore()
    var contentView = PlaylistPickerView(dismissAction: { pls.hostingController?.dismiss(animated: true, completion: nil)},
                                         shareAction: {
      pls.shareModule(module)
    },
                                         deleteAction: {
      pls.deleteModule(module)
    },
                                         store: pls)
    pls.setup()
    pls.doPrepare(mod: module)
    contentView.addToPlaylistAction = { pIndex in
      pls.addToPlaylist(playlistIndex: pIndex)
    }
    let hvc = UIHostingController(rootView: contentView)
    pls.hostingController = hvc
    hvc.modalPresentationStyle = .overFullScreen
    hvc.view.backgroundColor = .clear
    return hvc
  }

  // MARK: Setup
  func setup() {
    let viewController = self
    let interactor = PlaylistSelectorInteractor()
    let presenter = PlaylistSelectorPresenter()
    let router = PlaylistSelectorRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.dataStore = interactor
  }

  func doPrepare(mod: MMD) {
    let request = PlaylistSelector.PrepareSelection.Request(module: mod)
    interactor?.prepare(request: request)
  }

  func displaySelector(viewModel: PlaylistSelector.PrepareSelection.ViewModel) {
    self.viewModel = viewModel
  }

  func displayAppend(viewModel: PlaylistSelector.Append.ViewModel) {
    self.viewModel.status = viewModel.status

    if viewModel.status == .complete {
      hostingController?.dismiss(animated: true, completion: nil)
    }
  }

  func addToPlaylist(playlistIndex: Int) {
    switch viewModel.status {
    case .downloading:
      return
    default:
      interactor?.appendToPlaylist(request: PlaylistSelector.Append.Request(module: MMD(), playlistIndex: playlistIndex))
    }
  }

  func deleteModule(_ module: MMD) {
    guard viewModel.status == .complete else {
      return
    }

    interactor?.deleteModule(request: PlaylistSelector.Delete.Request(module: module))
    hostingController?.dismiss(animated: true, completion: nil)
  }

  func shareModule(_ module: MMD) {
    switch viewModel.status {
    case .downloading:
      return
    default:
      hostingController?.dismiss(animated: true, completion: {
        shareUtil.shareMod(mod: module)
      })
    }
  }

}
