//
//  Constants.swift
//  VLens
//
//  Created by Mohamed Taher on 10/11/2024.
//

struct Constants {
    
#if DEBUG
    static let IS_DEBUG                 = true
#else
    static let IS_DEBUG                 = false
#endif
    
    static let HOST                     = "https://api.vlenseg.com"
    
    struct Colors {
        static let accent               = "AccentColor"
        static let accentLight          = "AccentLightColor"
        static let accentDark           = "AccentDarkColor"
    }
    
    struct Font {
        static let bold                 = "Cairo Bold"
        static let light                = "Cairo Light"
        static let medium               = "Cairo Medium"
        static let regular              = "Cairo Regular"
    }
}
