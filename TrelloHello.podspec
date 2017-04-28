#
# Be sure to run `pod lib lint TrelloHello.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TrelloHello"
  s.version          = "0.0.1"
  s.summary          = "A Swift library to interact with the Trello API"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    TrelloHello is a simple Swift API to interact with Trello. It uses auth-tokens and currenly only supports basic GET requests.
                       DESC

  s.homepage         = "https://github.com/d53dave/TrelloHello"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'BSD 3-Clause'
  s.author           = { "Dave Sere" => "dave@d53dev.net" }
  s.source           = { :git => "https://github.com/d53dave/TrelloHello.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/d53r'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TrelloHello' => ['Pod/Assets/*.png']
  }

  s.dependency 'Alamofire', '~> 4.4'
  s.dependency 'AlamofireImage', '~> 3.1'
  s.dependency 'Decodable', '~> 0.5'
end
