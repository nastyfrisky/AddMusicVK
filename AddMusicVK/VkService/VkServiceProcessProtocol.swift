//
//  VkServiceProcessProtocol.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 26.05.2022.
//

protocol VkServiceProcessProtocol {
    var delegate: VkServiceOutput? { get set }
    func cancel()
}
