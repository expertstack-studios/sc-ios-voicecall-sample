//
//  AppDelegate.swift
//  SecuredVoiceCallSampleApp-SwiftUI
//
//  Created by Vivek Lalan on 23/07/24.
//

import PushKit
import SecuredCallsVoiceSDK
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		do {
			registerForVoIPPushes()
			try SecuredCallsVoice.initialize("jgjalcouim7uo0pdg16iof9incv97b191tlgie1rltb06kfa3q8")
			print("SecuredCalls initialized")

			UserDefaults.standard.set("iphone user", forKey: "userId")
			UserDefaults.standard.set("61451000121", forKey: "userIdentifier")
			if let userName = UserDefaults.standard.string(forKey: "userId"),
			   let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier")
			{
				print("SecuredCallsVoice login info = userName \(userName), identifier = \(userIdentifier)")
				Task {
					let securedCallsVoiceHasLoggedIn = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)

					print("SecuredCallsVoice login status = \(securedCallsVoiceHasLoggedIn)")
				}
			} else {
				print("Secured calls voice cannot be initalised as ther user name and idenitifer is not available.")
			}
		} catch {
			print("\(error.localizedDescription)")
		}

		return true
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("AppDelegate - Failed to register for remote notifications: \(error)")
	}

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let token = deviceToken.hexString
		Task {
			if let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") {
				var isProduction = true
				if let retVal = Bundle.main.object(forInfoDictionaryKey: "PushType") as? NSString {
					isProduction = retVal.boolValue
				}
				await SecuredCallsVoice.registerDeviceAsync(customerId: userIdentifier, token: token, isProduction: isProduction)
			} else {
				print("\(#function) user not registered")
			}
		}
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// Handle the notification

		let content = UNMutableNotificationContent()
		content.userInfo = userInfo
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

		// Pass the request to the SecuredCallsVoice SDK
		Task {
			await SecuredCallsVoice.processNotificationAsync(request: request, withContentHandler: { _ in
				// Process the notification content
				completionHandler(.newData)
			})
		}
	}

	private func registerForVoIPPushes() {
		let voipRegistry = PKPushRegistry(queue: nil)
		voipRegistry.delegate = self
		voipRegistry.desiredPushTypes = [.voIP]
	}
}

extension AppDelegate: PKPushRegistryDelegate {
	func pushRegistry(
		_ registry: PKPushRegistry,
		didUpdate pushCredentials: PKPushCredentials,
		for type: PKPushType
	) {
		if type == PKPushType.voIP {
			Task {
				await SecuredCallsVoice.registerVoipTokenAsync(
					token: pushCredentials.token
				)
			}
		}
	}

	func pushRegistry(
		_ registry: PKPushRegistry,
		didReceiveIncomingPushWith payload: PKPushPayload,
		for type: PKPushType,
		completion: @escaping () -> Void
	) {
		switch type {
		case .voIP:
			SecuredCallsVoice.reportNewInComingCall(payload: payload)
		default:
			return
		}
		completion()
	}
}

extension Data {
	var hexString: String {
		return map { String(format: "%02.2hhx", $0) }.joined()
	}
}
