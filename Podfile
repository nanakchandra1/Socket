# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'UserApp' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for UserApp
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '3.0'
          end
      end
  end

    pod 'Alamofire'
    pod 'Google/SignIn'
    pod 'GoogleMaps'
    pod 'Stripe'
    pod 'SwiftyJSON'
    pod ‘PulsingHalo’
    pod 'IQKeyboardManager'
    pod use_frameworks! 'SDWebImage'
    pod use_frameworks! 'MFSideMenu'
    pod 'Socket.IO-Client-Swift'
    pod 'GzipSwift'
    
end
