source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'CountrisCode' do
    pod 'RxSwift', '~> 3.0.0.beta.1'
    pod 'RxCocoa', '~> 3.0.0.beta.1'
    pod 'SwiftyJSON'
    pod 'Moya/RxSwift'
    pod 'Moya', '8.0.0-beta.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
