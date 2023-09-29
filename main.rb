require 'json'
require 'selenium-webdriver'
require_relative 'prettier'
require 'lineargs'

options = Selenium::WebDriver::Options.firefox
options.args << ARGL.parse("--profile","-profile /home/luca/.mozilla/firefox/nnc141tq.default-esr")

driver = Selenium::WebDriver.for :firefox, options: options

wait = Selenium::WebDriver::Wait.new(timeout: 60*60*3) # seconds
iframeID = ARGL.parse("--frame-id","playerDF")
skip_length = ARGL.parse("--skip-len",85)

while true
  print `clear`
  driver.switch_to.default_content

  iframe = wait.until {driver.find_element(:xpath, '//*[@id="%s"]' % iframeID)}
  checked "iFrame"
  driver.switch_to.frame iframe
  begin
    currentTime = driver.find_element(:xpath, '/html/body/div[1]/div/div[7]/div[4]/div')
    checked "Current Time element"
    video_player = driver.find_element(:xpath, '//*[@id="video_html5_wrapper_html5_api"]') 
    checked "Player"
  rescue
    sleep(1)
    next
  end

  driver.execute_script("var currentTimeEl = arguments[0];
    console.log('Element : ' + currentTimeEl)
    currentTimeEl.video_player = arguments[1];
    currentTimeEl.addEventListener('click',function skip_intro(evt){
      console.log(evt.target.video_player.currentTime);
      evt.target.video_player.currentTime += #{skip_length};
      // currentTimeEl.removeEventListener('click',skip_intro)
      console.log('Intro skipped!')
    })" \
  ,currentTime,video_player)
  
  loop{
    begin
      video_player.displayed?
    rescue
      puts "Next..."
      break
    end
    sleep(1)
  }

  puts "Loop"
end
