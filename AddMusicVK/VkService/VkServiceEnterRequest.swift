//
//  VkServiceEnterRequest.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 25.05.2022.
//

protocol VkServiceEnterRequestProtocol: AnyObject {
    func enter(response: String)
}

protocol VkServiceEnterRequestDelegate: AnyObject {
    func enter(response: String)
}

final class VkServiceEnterRequest: VkServiceEnterRequestProtocol {
    
    // MARK: - Public Properties
    
    weak var delegate: VkServiceEnterRequestDelegate?
    
    // MARK: - Private Properties
    
    private var isEntered = false
    
    // MARK: - Initializers
    
    init(delegate: VkServiceEnterRequestDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    
    func enter(response: String) {
        guard isEntered == false else { return }
        isEntered = true
        delegate?.enter(response: response)
    }
}
