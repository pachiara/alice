require 'test_helper'

class DetectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  
  def testPost
    url = URI.parse('http://localhost:3000/detection/')
    request = Net::HTTP::Post.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8' standalone='no'?>
    <licenseSummary>
    <dependencies>
    <dependency>
      <groupId>commons-logging</groupId>
      <artifactId>commons-logging</artifactId>
      <version>1.1.1</version>
      <licenses>
        <license>
          <name>The Apache Software License, Version 2.0</name>
          <url>http://www.apache.org/licenses/LICENSE-2.0.txt</url>
          <distribution>repo</distribution>
        </license>
      </licenses>
    </dependency>
    </dependencies>
    </licenseSummary>"
    
    response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    assert_equal '201 Created', response.get_fields('Status')[0]
  end

  
end
