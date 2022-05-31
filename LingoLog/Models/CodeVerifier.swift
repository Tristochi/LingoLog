//
//  LingoLogModel.swift
//  LingoLog
//
//  Created by Tristan Szakacs on 5/23/22.
//
// Written following tutorial at https://bootstragram.com/blog/oauth-pkce-swift-secure-code-verifiers-and-code-challenges/

import Foundation
import CryptoKit


precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    f(a)
}

func |> <A, B>(a: A, f: (A) throws -> B) throws -> B {
    try f(a)
}

enum PKCEError: Error {
    case failedToGenerateRandomOctets
    case failedToCreateChallengeForVerifier
}


func generateOctetsForCrypto(count: Int) throws -> [UInt8] {
    var octets = [UInt8](repeating: 0, count: count)
    let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
        
    if status == errSecSuccess {
        return octets
    }else {
        throw PKCEError.failedToGenerateRandomOctets
    }
}

//Swift template func
func base64URLEncode<S>(octets: S) -> String where S : Sequence, UInt8 == S.Element{
    let data = Data(octets)
    return data.base64EncodedString()
        .replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .trimmingCharacters(in: .whitespaces)
}
    
let codeVerifier = try! 32
    |> generateOctetsForCrypto
    |> base64URLEncode

func challenge(for verifier: String) throws -> String {
    let challenge = verifier
        .data(using: .ascii)
        .map { SHA256.hash(data: $0) }
        .map { base64URLEncode(octets: $0) }
    
    if let challenge = challenge {
        return challenge
    }else {
        throw PKCEError.failedToCreateChallengeForVerifier
    }
}

func assertEqual<S>(_ a: S, _ b: S) where S: Equatable {
    if a == b {
        print("✅ \(a) == \(b)")
    } else {
        fatalError("Assertion failed.")
    }
}



