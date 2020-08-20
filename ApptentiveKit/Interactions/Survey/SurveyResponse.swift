//
//  SurveyResponse.swift
//  ApptentiveKit
//
//  Created by Frank Schmitt on 6/12/20.
//  Copyright © 2020 Apptentive. All rights reserved.
//

import Foundation

typealias SurveyResponse = [String: [SurveyQuestionResponse]]

enum SurveyQuestionResponse: Equatable {
    case choice(String)
    case freeform(String)
    case range(Int)
    case other(String, String)
}
