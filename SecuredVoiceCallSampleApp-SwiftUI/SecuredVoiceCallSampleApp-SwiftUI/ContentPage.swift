//
//  ContentView.swift
//  SecuredVoiceCallSampleApp-SwiftUI
//
//  Created by Vivek Lalan on 23/07/24.
//

import SecuredCallsVoiceSDK
import SwiftUI

struct ContentPage: View {
	let viewModel = ContentPageViewModel()

	var body: some View {
		ZStack {
			Color.white
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 16) {
				Text("Calling Button")
					.font(.title)
					.foregroundColor(.black)
				ScVoiceCallButton(buttonText: "Demo App Call", numberToCall: "61450000001") {
					print("Calling")
				}
				.frame(width: 120)
				
				Spacer()
			}
			.padding()
		}
	}
}

#Preview {
	ContentPage()
}
