import UIKit

public enum SystemColors {
  public static var label: UIColor {
    if #available(iOS 13, *) {
      return .label
    }
    return .black
  }
  public static var secondaryLabel: UIColor {
    if #available(iOS 13, *) {
      return .secondaryLabel
    }
    return .lightGray
  }
  public static var systemBackground: UIColor {
    if #available(iOS 13, *) {
      return .systemBackground
    }
    return .white
  }
  public static var secondarySystemBackground: UIColor {
    if #available(iOS 13, *) {
      return .secondarySystemBackground
    }
    return UIColor(white: 247/255, alpha: 1)
  }
  public static var systemRed: UIColor {
    if #available(iOS 13, *) {
      return .systemRed
    }
    return .red
  }
  public static var systemBlue: UIColor {
    if #available(iOS 13, *) {
      return .systemBlue
    }
    return .blue
  }
  public static var systemGray4: UIColor {
    if #available(iOS 13, *) {
      return .systemGray4
    }
    return UIColor(red: 209/255,
                   green: 209/255,
                   blue: 213/255, alpha: 1)
  }
  public static var systemSeparator: UIColor {
    if #available(iOS 13, *) {
      return .opaqueSeparator
    }
    return UIColor(red: 198/255,
                   green: 198/255,
                   blue: 200/255, alpha: 1)
  }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            self.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
