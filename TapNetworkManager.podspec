SDWebImageDependencyVersion         = '>= 4.4' unless defined? SDWebImageDependencyVersion
TapAdditionsKitDependencyVersion    = '>= 1.2' unless defined? TapAdditionsKitDependencyVersion

Pod::Spec.new do |tapNetworkManager|
    
    tapNetworkManager.platform              = :ios
    tapNetworkManager.ios.deployment_target = '8.0'
    tapNetworkManager.swift_version         = '4.2'
    tapNetworkManager.name                  = 'TapNetworkManager'
    tapNetworkManager.summary               = 'Lightweight network manager for iOS.'
    tapNetworkManager.requires_arc          = true
    tapNetworkManager.version               = '1.2.3'
    tapNetworkManager.license               = { :type => 'MIT', :file => 'LICENSE' }
    tapNetworkManager.author                = { 'Tap Payments' => 'hello@tap.company' }
    tapNetworkManager.homepage              = 'https://github.com/Tap-Payments/TapNetworkManager-iOS'
    tapNetworkManager.source                = { :git => 'https://github.com/Tap-Payments/TapNetworkManager-iOS.git', :tag => tapNetworkManager.version.to_s }
    tapNetworkManager.default_subspecs      = 'Core'
    
    tapNetworkManager.subspec 'Core' do |core|
    
        core.source_files = 'TapNetworkManager/Source/Core/*.swift'
    
    end
    
    tapNetworkManager.subspec 'ImageLoading' do |imageLoading|
    
        imageLoading.dependency 'SDWebImage/Core',                          SDWebImageDependencyVersion
        imageLoading.dependency 'TapAdditionsKit/Foundation/URLSession',    TapAdditionsKitDependencyVersion
        imageLoading.dependency 'TapNetworkManager/Core'
        
        imageLoading.source_files = 'TapNetworkManager/Source/ImageLoading/*.swift'
    
    end
    
    tapNetworkManager.subspec 'Reachability' do |reachability|
    
        reachability.source_files = 'TapNetworkManager/Source/Reachability/*.swift'
    
    end
end
