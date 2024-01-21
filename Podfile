# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'Shedulety' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Shedulety

	pod 'SnapKit', '~> 5.6.0'
	pod 'RealmSwift'

  target 'SheduletyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SheduletyUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end

