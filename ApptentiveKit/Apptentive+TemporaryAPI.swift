//
//  Apptentive+TemporaryAPI.swift
//  ApptentiveKit
//
//  Created by Frank Schmitt on 8/10/20.
//  Copyright © 2020 Apptentive. All rights reserved.
//

import UIKit

extension Apptentive {
    /// Manually presents an interaction to the user.
    /// - Parameters:
    ///   - interaction: The `Interaction` instance representing the interaction.
    ///   - presentingViewController: A view controller that will be tasked with presenting a view-controller-based interaction.
    // - Throws: An error if the interaction is invalid or if—for view-controller-based interactions—the view controller is  either`nil` or not currently capable of presenting the view controller for the interaction.
    public func presentInteraction(_ interaction: Interaction, from presentingViewController: UIViewController) throws {
        try self.interactionPresenter.presentInteraction(interaction, from: presentingViewController)
    }
}
