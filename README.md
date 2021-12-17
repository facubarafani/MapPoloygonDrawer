# How to use
1. In order to make the project buildeable you must create a **.swift** file named `Keys.swift` on the following path:

        PROJECT_ROOT/Resources/Keys.swift

2. The file mentioned before should contain the following code:

        class Keys {
            static let googleMaps = "YOUR_GOOGLE_API_KEY"
        }

3. **IMPORTANT**  In addition to this, you must run `pod install` in order to install all project dependencies.