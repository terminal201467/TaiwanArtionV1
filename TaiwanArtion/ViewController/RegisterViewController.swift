//
//  RegisterViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/14.
//

import UIKit

class RegisterViewController: UIViewController {

    private let registerView = RegisterView()
    
    private let viewModel = RegisterViewModel()
    
    private var firstStepView: PhoneVerifyView?
    
    private var secondStepView: AccountPasswordView?
    
    private var thirdStepView: EmailVerifyView?
    
    //MARK: -LifeCycle
    override func loadView() {
        super.loadView()
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setCollectionView()
        setStepAddContainer()
        setInputInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //停止倒數
    }
    
    //MARK: - Methods
    private func setNavigationBar() {
        title = "會員註冊"
        let backButton = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setCollectionView() {
        registerView.stepCollectionView.dataSource = self
        registerView.stepCollectionView.delegate = self
    }
    
    private func layoutViews(parentView: UIView, childView: UIView) {
        parentView.addSubview(childView)
        childView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setStepAddContainer() {
        switch viewModel.getCurrentStep() {
        case .phoneVerify:
            firstStepView = PhoneVerifyView()
            layoutViews(parentView: registerView.containerView, childView: firstStepView!)
            firstStepView?.toNextStep = { [weak self] in
                guard let self = self else { return }
                self.viewModel.setCurrentStep(step: .acountPassword)
                self.firstStepView?.removeFromSuperview()
                self.registerView.stepCollectionView.reloadData()
                self.setStepAddContainer()
            }
        case .acountPassword:
            secondStepView = AccountPasswordView()
            layoutViews(parentView: registerView.containerView, childView: secondStepView!)
            secondStepView?.toNextStep = { [weak self] in
                guard let self = self else { return }
                self.viewModel.setCurrentStep(step: .emailVerify)
                self.secondStepView?.removeFromSuperview()
                self.registerView.stepCollectionView.reloadData()
                self.setStepAddContainer()
            }
        case .emailVerify:
            thirdStepView = EmailVerifyView()
            layoutViews(parentView: registerView.containerView, childView: thirdStepView!)
            thirdStepView?.toNextStep = { [weak self] in
                guard let self = self else { return }
                let registerSucceedViewController = RegisterSucceedViewController()
                let personInfoViewController = PersonalInfoViewController()
                registerSucceedViewController.modalPresentationStyle = .overFullScreen
                registerSucceedViewController.pushToControllerAction = { [weak self] in
                    self?.navigationController?.pushViewController(personInfoViewController, animated: true)
                }
                registerSucceedViewController.popViewControllerAction = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                self.present(registerSucceedViewController, animated: true)
                self.thirdStepView?.removeFromSuperview()
                self.registerView.stepCollectionView.reloadData()
            }
        case .complete: break
        }
    }
    
    private func setInputInfo() {
        firstStepView?.changedPhoneText = { [weak self] changedText in
            guard let self = self else { return }
            AppLogger.debug("電話號碼輸入中", category: .ui)
            self.viewModel.input.inputPhoneNumberRelay.accept(changedText)
        }
        //發送認證碼給手機門號
        firstStepView?.toSendVerifyCode = { [weak self] in
            self?.viewModel.input.inputSendVerifyCodeActionSubject.onNext(())
        }
        //驗證驗證碼
        firstStepView?.toVerifiedMessengeCode = { [weak self] in
            self?.viewModel.input.inputCheckVerifyCodeSubject.onNext(())
        }
        //接收驗證碼
        firstStepView?.toVerifyChangedCode = { [weak self] verifyCode in
            self?.viewModel.input.inputMessengeVerifyCodeRelay.accept(verifyCode)
        }
    }
}
extension RegisterViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.stepsNumberOfRowInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellnfo = viewModel.stepsCellForRowAt(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegisterStepCollectionViewCell.reuseIdentifier, for: indexPath) as! RegisterStepCollectionViewCell
        cell.configure(isCurrentStep: cellnfo.isSelected, step: indexPath.row + 1, stepTitle: cellnfo.stepString)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.width - 16 * 4) / 4
        let cellHeight = 60.0
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 16, bottom: 12, right: 16)
    }
}
