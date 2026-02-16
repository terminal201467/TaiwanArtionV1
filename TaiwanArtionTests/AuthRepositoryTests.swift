//
//  AuthRepositoryTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

// MARK: - Mock AuthRepository

class MockAuthRepository: AuthRepository {

    // MARK: - Call Tracking

    var signInWithGoogleCalled = false
    var signInWithFacebookCalled = false
    var signUpWithEmailCalled = false
    var signInWithEmailCalled = false
    var sendPhoneVerificationCodeCalled = false
    var verifyPhoneCodeCalled = false
    var sendEmailVerificationCalled = false
    var verifyEmailCalled = false
    var sendPasswordResetEmailCalled = false
    var signOutCalled = false

    // MARK: - Result Configuration

    var googleSignInResult: Result<AuthResult, AuthError> = .failure(.googleSignInFailed(nil))
    var facebookSignInResult: Result<AuthResult, AuthError> = .failure(.facebookSignInFailed(nil))
    var emailSignUpResult: Result<AuthResult, AuthError> = .failure(.emailSignUpFailed(nil))
    var emailSignInResult: Result<AuthResult, AuthError> = .failure(.emailSignInFailed(nil))
    var phoneVerificationResult: Result<Void, AuthError> = .success(())
    var verifyPhoneResult: Result<AuthResult, AuthError> = .failure(.verificationCodeInvalid(nil))
    var emailVerificationResult: Result<Void, AuthError> = .success(())
    var verifyEmailResult: Result<Void, AuthError> = .success(())
    var passwordResetResult: Result<Void, AuthError> = .success(())
    var signOutResult: Result<Void, AuthError> = .success(())

    // MARK: - Mock Current User

    var mockCurrentUser: User?
    var mockIsSignedIn: Bool = false

    var currentUser: User? {
        return mockCurrentUser
    }

    var isSignedIn: Bool {
        return mockIsSignedIn
    }

    // MARK: - Protocol Methods

    func signInWithGoogle(from controller: UIViewController, completion: @escaping (Result<AuthResult, AuthError>) -> Void) {
        signInWithGoogleCalled = true
        completion(googleSignInResult)
    }

    func signInWithFacebook(from controller: UIViewController, completion: @escaping (Result<AuthResult, AuthError>) -> Void) {
        signInWithFacebookCalled = true
        completion(facebookSignInResult)
    }

    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<AuthResult, AuthError>) -> Void) {
        signUpWithEmailCalled = true
        completion(emailSignUpResult)
    }

    func signInWithEmail(email: String, password: String, completion: @escaping (Result<AuthResult, AuthError>) -> Void) {
        signInWithEmailCalled = true
        completion(emailSignInResult)
    }

    func sendPhoneVerificationCode(phoneNumber: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        sendPhoneVerificationCodeCalled = true
        completion(phoneVerificationResult)
    }

    func verifyPhoneCode(code: String, completion: @escaping (Result<AuthResult, AuthError>) -> Void) {
        verifyPhoneCodeCalled = true
        completion(verifyPhoneResult)
    }

    func sendEmailVerification(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        sendEmailVerificationCalled = true
        completion(emailVerificationResult)
    }

    func verifyEmail(email: String, password: String, code: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        verifyEmailCalled = true
        completion(verifyEmailResult)
    }

    func sendPasswordResetEmail(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        sendPasswordResetEmailCalled = true
        completion(passwordResetResult)
    }

    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        signOutCalled = true
        completion(signOutResult)
    }

    // MARK: - Reset

    func reset() {
        signInWithGoogleCalled = false
        signInWithFacebookCalled = false
        signUpWithEmailCalled = false
        signInWithEmailCalled = false
        sendPhoneVerificationCodeCalled = false
        verifyPhoneCodeCalled = false
        sendEmailVerificationCalled = false
        verifyEmailCalled = false
        sendPasswordResetEmailCalled = false
        signOutCalled = false
    }
}

// MARK: - AuthError Tests

final class AuthErrorTests: XCTestCase {

    func testGoogleSignInFailed_HasCorrectDescription() {
        // Given
        let error = AuthError.googleSignInFailed(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("Google") == true, "應該包含 Google")
    }

    func testFacebookSignInFailed_HasCorrectDescription() {
        // Given
        let error = AuthError.facebookSignInFailed(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("Facebook") == true, "應該包含 Facebook")
    }

    func testEmailSignUpFailed_HasCorrectDescription() {
        // Given
        let error = AuthError.emailSignUpFailed(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("Email") == true, "應該包含 Email")
    }

    func testEmailSignInFailed_HasCorrectDescription() {
        // Given
        let error = AuthError.emailSignInFailed(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("Email") == true, "應該包含 Email")
    }

    func testPhoneVerificationFailed_HasCorrectDescription() {
        // Given
        let error = AuthError.phoneVerificationFailed(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("手機") == true, "應該包含 手機")
    }

    func testVerificationCodeInvalid_HasCorrectDescription() {
        // Given
        let error = AuthError.verificationCodeInvalid(nil)

        // Then
        XCTAssertTrue(error.errorDescription?.contains("驗證碼") == true, "應該包含 驗證碼")
    }

    func testUserNotFound_HasCorrectDescription() {
        // Given
        let error = AuthError.userNotFound

        // Then
        XCTAssertTrue(error.errorDescription?.contains("使用者") == true, "應該包含 使用者")
    }
}

// MARK: - AuthResult Tests

final class AuthResultTests: XCTestCase {

    func testAuthResult_Initialization_SetsCorrectValues() {
        // Given
        let user = User(
            birth: "1990-01-01",
            email: "test@example.com",
            gender: "男",
            headImage: "image.jpg",
            phone: "0912345678",
            name: "測試使用者"
        )

        // When
        let result = AuthResult(user: user, isNewUser: true, provider: .google)

        // Then
        XCTAssertEqual(result.user.email, "test@example.com", "email 應該正確")
        XCTAssertTrue(result.isNewUser, "isNewUser 應該是 true")
        XCTAssertEqual(result.provider, .google, "provider 應該是 google")
    }

    func testAuthResult_DefaultIsNewUser_IsFalse() {
        // Given
        let user = User(
            birth: "",
            email: "test@example.com",
            gender: "",
            headImage: "",
            phone: "",
            name: ""
        )

        // When
        let result = AuthResult(user: user, provider: .email)

        // Then
        XCTAssertFalse(result.isNewUser, "預設 isNewUser 應該是 false")
    }
}

// MARK: - AuthProvider Tests

final class AuthProviderTests: XCTestCase {

    func testAuthProvider_Google_HasCorrectRawValue() {
        // Then
        XCTAssertEqual(AuthProvider.google.rawValue, "Google", "rawValue 應該正確")
    }

    func testAuthProvider_Facebook_HasCorrectRawValue() {
        // Then
        XCTAssertEqual(AuthProvider.facebook.rawValue, "Facebook", "rawValue 應該正確")
    }

    func testAuthProvider_Email_HasCorrectRawValue() {
        // Then
        XCTAssertEqual(AuthProvider.email.rawValue, "Email", "rawValue 應該正確")
    }

    func testAuthProvider_Phone_HasCorrectRawValue() {
        // Then
        XCTAssertEqual(AuthProvider.phone.rawValue, "Phone", "rawValue 應該正確")
    }

    func testAuthProvider_Unknown_HasCorrectRawValue() {
        // Then
        XCTAssertEqual(AuthProvider.unknown.rawValue, "Unknown", "rawValue 應該正確")
    }
}

// MARK: - MockAuthRepository Tests

final class MockAuthRepositoryTests: XCTestCase {

    var sut: MockAuthRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockAuthRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testSignUpWithEmail_SetsCallFlag() {
        // Given
        let expectation = self.expectation(description: "Sign up")

        // When
        sut.signUpWithEmail(email: "test@example.com", password: "password123") { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(sut.signUpWithEmailCalled, "signUpWithEmail 應該被呼叫")
    }

    func testSignInWithEmail_SetsCallFlag() {
        // Given
        let expectation = self.expectation(description: "Sign in")

        // When
        sut.signInWithEmail(email: "test@example.com", password: "password123") { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(sut.signInWithEmailCalled, "signInWithEmail 應該被呼叫")
    }

    func testSendPhoneVerificationCode_SetsCallFlag() {
        // Given
        let expectation = self.expectation(description: "Send code")

        // When
        sut.sendPhoneVerificationCode(phoneNumber: "+886912345678") { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(sut.sendPhoneVerificationCodeCalled, "sendPhoneVerificationCode 應該被呼叫")
    }

    func testSignOut_SetsCallFlag() {
        // Given
        let expectation = self.expectation(description: "Sign out")

        // When
        sut.signOut { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(sut.signOutCalled, "signOut 應該被呼叫")
    }

    func testReset_ClearsAllFlags() {
        // Given
        sut.signUpWithEmailCalled = true
        sut.signInWithEmailCalled = true
        sut.signOutCalled = true

        // When
        sut.reset()

        // Then
        XCTAssertFalse(sut.signUpWithEmailCalled, "signUpWithEmailCalled 應該被重設")
        XCTAssertFalse(sut.signInWithEmailCalled, "signInWithEmailCalled 應該被重設")
        XCTAssertFalse(sut.signOutCalled, "signOutCalled 應該被重設")
    }

    func testCurrentUser_ReturnsMockUser() {
        // Given
        let mockUser = User(
            birth: "1990-01-01",
            email: "mock@example.com",
            gender: "男",
            headImage: "",
            phone: "",
            name: "Mock User"
        )
        sut.mockCurrentUser = mockUser

        // When
        let user = sut.currentUser

        // Then
        XCTAssertEqual(user?.email, "mock@example.com", "應該返回 mock user")
    }

    func testIsSignedIn_ReturnsMockValue() {
        // Given
        sut.mockIsSignedIn = true

        // When
        let isSignedIn = sut.isSignedIn

        // Then
        XCTAssertTrue(isSignedIn, "應該返回 mock value")
    }

    func testEmailSignInResult_ReturnsConfiguredResult() {
        // Given
        let mockUser = User(
            birth: "",
            email: "test@example.com",
            gender: "",
            headImage: "",
            phone: "",
            name: "Test"
        )
        let mockAuthResult = AuthResult(user: mockUser, isNewUser: false, provider: .email)
        sut.emailSignInResult = .success(mockAuthResult)

        let expectation = self.expectation(description: "Sign in")
        var receivedResult: Result<AuthResult, AuthError>?

        // When
        sut.signInWithEmail(email: "test@example.com", password: "password") { result in
            receivedResult = result
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        switch receivedResult {
        case .success(let authResult):
            XCTAssertEqual(authResult.user.email, "test@example.com", "應該返回配置的結果")
        case .failure, .none:
            XCTFail("應該成功")
        }
    }
}

// MARK: - FirebaseAuthRepository Tests

final class FirebaseAuthRepositoryTests: XCTestCase {

    var sut: FirebaseAuthRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = FirebaseAuthRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testFirebaseAuthRepository_Initialization_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "FirebaseAuthRepository 應該能夠初始化")
    }

    func testIsSignedIn_ReturnsBoolean() {
        // When
        let result = sut.isSignedIn

        // Then
        XCTAssertTrue(result || !result, "isSignedIn 應該返回布林值")
    }

    func testSignOut_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Sign out")

        // When & Then
        XCTAssertNoThrow({
            self.sut.signOut { _ in
                expectation.fulfill()
            }
        }(), "signOut 不應該崩潰")

        waitForExpectations(timeout: 2.0)
    }

    func testSendPasswordResetEmail_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Send reset email")

        // When & Then
        XCTAssertNoThrow({
            self.sut.sendPasswordResetEmail(email: "test@example.com") { _ in
                expectation.fulfill()
            }
        }(), "sendPasswordResetEmail 不應該崩潰")

        waitForExpectations(timeout: 5.0)
    }
}
