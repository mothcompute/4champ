//
//  PlaylistSelectorPresenter.swift
//  4champ
//
//  Created by Aleksi Sitomaniemi on 13.3.2020.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol PlaylistSelectorPresentationLogic
{
    func presentSelector(response: PlaylistSelector.PrepareSelection.Response)
    func presentAppend(response: PlaylistSelector.Append.Response)
}

class PlaylistSelectorPresenter: PlaylistSelectorPresentationLogic
{
    weak var viewController: PlaylistSelectorDisplayLogic?
    
    func presentSelector(response: PlaylistSelector.PrepareSelection.Response)
    {
        var defaultString = ""
        var options:[String] = []
        for pl in response.playlistOptions {
            
                let modTick = pl.modules.contains(response.module.id ?? 0) ? "✓" : ""
                let modPlay = (pl.id == modulePlayer.currentPlaylist?.plId) ? "▶️" : ""
                let plstring = "\(modTick)\(modPlay) \(pl.name!) (\(pl.modules.count))"
            
            if pl.id == "default" {
                defaultString = "\(modTick)\(modPlay) \("PlaylistView_DefaultPlaylist".l13n()) (\(pl.modules.count))"
                options.append(defaultString)
            } else {
                options.append(plstring)
            }
        }
        
        let moduleName = String.init(format: "LockScreen_Playing".l13n(), response.module.name ?? "", response.module.composer ?? "")
        
        let viewModel = PlaylistSelector.PrepareSelection.ViewModel(module: moduleName, playlistOptions: options, status: .unknown)
        viewController?.displaySelector(viewModel: viewModel)
    }
    
    func presentAppend(response: PlaylistSelector.Append.Response) {
        let viewModel = PlaylistSelector.Append.ViewModel(status: response.status)
        viewController?.displayAppend(viewModel: viewModel)
    }
}
