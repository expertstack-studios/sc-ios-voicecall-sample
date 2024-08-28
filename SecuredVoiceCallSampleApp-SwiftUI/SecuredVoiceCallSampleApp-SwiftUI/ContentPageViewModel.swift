//
//  ContentPageViewModel.swift
//  SecuredVoiceCallSampleApp-SwiftUI
//
//  Created by Vivek Lalan on 23/07/24.
//

import Foundation
import SecuredCallsVoiceSDK

class ContentPageViewModel {
	init() {
		SecuredCallsVoice.setCallStatusDelegate(self)
	}
}

extension ContentPageViewModel: ICallStatusDelegate {
	func callStarted() {
		print("call started callback")
	}

	func callEnded() {
		print("call ended callback")
	}
}
