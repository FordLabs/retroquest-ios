///**
/**
Copyright © 2019 Ford Motor Company. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var convertPascalCaseToLowerCaseWithSpaces: String {
        var firstCharacter = true
        var formattedString = ""
        for character in self {
            let charAsString = String(character)
            if !firstCharacter && charAsString == charAsString.uppercased() {
                formattedString.append(" ")
            }
            formattedString.append(charAsString.lowercased())
            firstCharacter = false
        }
        return formattedString
    }
}

extension StringProtocol {
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...].range(of: string, options: options) {
            result.append(range.lowerBound)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension UIColor {
    convenience init(hexString: String) {
        self.init(hexString: hexString, alpha: 255)
    }

    convenience init(hexString: String, alpha: UInt64) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (alpha, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (alpha, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (alpha, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        if let block = actions[index].value(forKey: "handler") {
            let blockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
            let handler = unsafeBitCast(blockPtr, to: AlertHandler.self)
            handler(actions[index])
        }
    }
}

extension UILabel {
    // Pass value for any one of both parameters and see result
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
        )

        self.attributedText = attributedString
    }

    func withText(_ text: String) -> UILabel {
        self.text = text
        return self
    }

    func withColor(_ color: UIColor) -> UILabel {
        self.textColor = color
        return self
    }

    public func withFont(_ font: UIFont) -> UILabel {
        self.font = font
        return self
    }
}

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

public struct ViewConstraints {
    var top: NSLayoutConstraint
    var left: NSLayoutConstraint
    var bottom: NSLayoutConstraint
    var right: NSLayoutConstraint

    public func setEdgeInsets(_ insets: UIEdgeInsets) {
        top.constant = insets.top
        left.constant = insets.left
        bottom.constant = insets.bottom
        right.constant = insets.right
    }

    internal func activateConstraints(omit: NSLayoutConstraint.Attribute = .notAnAttribute) {
        var constraints = [top, left, bottom, right]
        switch omit {
        case NSLayoutAttribute.top: _ = constraints.remove(at: 0)
        case NSLayoutAttribute.leading, NSLayoutAttribute.left: _ = constraints.remove(at: 1)
        case NSLayoutAttribute.bottom: _ = constraints.remove(at: 2)
        case NSLayoutAttribute.trailing, NSLayoutAttribute.right: _ = constraints.remove(at: 3)
        default: break
        }

        NSLayoutConstraint.activate(constraints)
    }
}

extension UIView {
    func anchorTopToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorTopTo((superview?.topAnchor)!, offset: offset)
    }

    func anchorBottomToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorBottomTo((superview?.bottomAnchor)!, offset: offset)
    }

    func anchorLeftToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorLeftTo((superview?.leftAnchor)!, offset: offset)
    }

    func anchorRightToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorRightTo((superview?.rightAnchor)!, offset: offset)
    }

    func anchorLeadingToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorLeadingTo((superview?.leadingAnchor)!, offset: offset)
    }

    func anchorTrailingToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchorTrailingTo((superview?.trailingAnchor)!, offset: offset)
    }

    func anchorCenterXToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.centerXAnchor, toAnchor: (superview?.centerXAnchor)!, offset: offset)
    }

    func anchorCenterYToSuperview(offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.centerYAnchor, toAnchor: (superview?.centerYAnchor)!, offset: offset)
    }

    func anchorCenterToView(_ view: UIView) {
        _ = anchor(self.centerXAnchor, toAnchor: view.centerXAnchor)
        _ = anchor(self.centerYAnchor, toAnchor: view.centerYAnchor)
    }

    func anchorCenterYToView(_ view: UIView) {
        _ = anchor(self.centerYAnchor, toAnchor: view.centerYAnchor)
    }

    func anchorCenterXToView(_ view: UIView) {
        _ = anchor(self.centerXAnchor, toAnchor: view.centerXAnchor)
    }

    func anchorCenterToSuperview() {
        _ = anchorCenterXToSuperview()
        _ = anchorCenterYToSuperview()
    }

    func anchorEdgesToSuperView(
            _ insets: UIEdgeInsets = UIEdgeInsets.zero,
            omit: NSLayoutConstraint.Attribute = .notAnAttribute) -> ViewConstraints? {
        guard let superview = superview else {
            assert(false, "view must be added before setting up constraints")
            return nil
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = ViewConstraints(
                top: prepareAnchor(topAnchor, toAnchor: superview.topAnchor, offset: insets.top),
                left: prepareAnchor(leftAnchor, toAnchor: superview.leftAnchor, offset: insets.left),
                bottom: prepareAnchor(bottomAnchor, toAnchor: superview.bottomAnchor, offset: insets.bottom),
                right: prepareAnchor(rightAnchor, toAnchor: superview.rightAnchor, offset: insets.right))
        constraints.activateConstraints(omit: omit)
        return constraints
    }

    func anchorTopTo(_ toAnchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.topAnchor, toAnchor: toAnchor, offset: offset)
    }

    func anchorBottomTo(_ toAnchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.bottomAnchor, toAnchor: toAnchor, offset: offset)
    }

    func anchorLeftTo(_ toAnchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.leftAnchor, toAnchor: toAnchor, offset: offset)
    }

    func anchorRightTo(_ toAnchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.rightAnchor, toAnchor: toAnchor, offset: offset)
    }

    func anchorLeadingTo(_ toAnchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.leadingAnchor, toAnchor: toAnchor, offset: offset)
    }

    func anchorTrailingTo(_ toAnchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor(self.trailingAnchor, toAnchor: toAnchor, offset: offset)
    }

    // MARK: anchorTo dimensions
    func anchorHeightTo(_ value: CGFloat) -> NSLayoutConstraint {
        return anchor(self.heightAnchor, constant: value)
    }

    func anchorWidthTo(_ value: CGFloat) -> NSLayoutConstraint {
        return anchor(self.widthAnchor, constant: value)
    }

    func anchorWidthEqualToView(_ view: UIView) -> NSLayoutConstraint {
        return anchor(self.widthAnchor, toAnchor: view.widthAnchor, offset: 0)
    }

    func anchorHeightEqualToView(_ view: UIView) -> NSLayoutConstraint {
        return anchor(self.heightAnchor, toAnchor: view.heightAnchor, offset: 0)
    }

    func anchorAspectRatioTo(_ value: CGFloat) -> NSLayoutConstraint {
        return activateConstraint(self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: value))
    }

    fileprivate func prepareAnchor<T>(_ anchor: NSLayoutAnchor<T>,
                                      toAnchor: NSLayoutAnchor<T>,
                                      offset: CGFloat = 0) -> NSLayoutConstraint {
        return anchor.constraint(equalTo: toAnchor, constant: offset)
    }

    fileprivate func anchor<T>(
        _ anchor: NSLayoutAnchor<T>,
        toAnchor: NSLayoutAnchor<T>,
        offset: CGFloat = 0) -> NSLayoutConstraint {
        return activateConstraint(prepareAnchor(anchor, toAnchor: toAnchor, offset: offset))
    }

    fileprivate func anchor(_ anchor: NSLayoutDimension, constant: CGFloat) -> NSLayoutConstraint {
        return activateConstraint(anchor.constraint(equalToConstant: constant))
    }

    fileprivate func activateConstraint(_ constraint: NSLayoutConstraint) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        constraint.isActive = true
        return constraint
    }
}

extension UIFont {
    static func retroquestBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-Bold", size: size)!
    }

    static func retroquestRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Quicksand-Medium", size: size)!
    }
}

public protocol ViewControllerPresenter {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?)
}

extension UIViewController: ViewControllerPresenter {}

extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "spinner"
    }

    public func presentAlertControllerWithTitle(
            _ title: String,
            presenter: ViewControllerPresenter,
            andMessage message: String,
            defaultHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: defaultHandler))

        presenter.present(alertController, animated: true, completion: nil)
    }

    public func showSpinner() {
        let spinnerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

        objc_setAssociatedObject(self, &AssociatedKeys.DescriptiveName, spinnerView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        spinnerView.frame = UIScreen.main.bounds
        spinnerView.isHidden = false
        self.view.addSubview(spinnerView)
        spinnerView.startAnimating()
    }

    public func hideSpinner() {
        if let spinner = objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? UIActivityIndicatorView {
            spinner.stopAnimating()
        }
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
