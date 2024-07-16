#using Pkg
#tmpd = mktempdir()
#Pkg.activate(tmpd)
#Pkg.add("PyCall")
#Pkg.add("WebDriver")

#using WebDriver
using PyCall
using Test
using Conda
Conda.add("selenium")
@testset "selenium" begin
    webdriver = pyimport("selenium.webdriver")
    bubi = pyimport("selenium.webdriver.common.by")
    pathlib = pyimport("pathlib")
    #webdriver.Edge(),webdriver.Chrome(),webdriver.Firefox() ,webdriver.Ie(),webdriver.Opera(),webdriver.PhantomJS(),webdriver.Safari(),webdriver.Android() 

    #you will need to download chromdriver for the next call to work
    #also chromedriver.exe needs to be in PATH (windows environment variable) for this to work 
    #also the chrome version you have needs to match the chromedriver version
    #driver = webdriver.Firefox()

    #from selenium import webdriver
    #from selenium.webdriver.common.by import By

    print("before driv init")
    options = webdriver.FirefoxOptions()
    options.add_argument("--headless=new")

    binpath = "/home/abel/Documents/Iskola/Egyetem/Software_Project/taijainteractive.jl/test/chrome-linux64/chrome"
    if Sys.islinux()
        binpath = Base.source_path() * "../linux-headless-shell"
    elseif Sys.isapple()
        binpath = Base.source_path() * "../chrome"
    elseif Sys.iswindows()
        binpath = Base.source_path() * "../windows-headless-shell.exe"
    end
    print(binpath)
    #options.binary_location = binpath

    #service = webdriver.ChromeService(executable_path=binpath)

    driver = webdriver.Firefox(options)

    #driver = webdriver.Chrome(options)
    print("before http")
    driver.get("https://www.selenium.dev/selenium/web/web-form.html")

    title = driver.title
    #print(title)

    driver.implicitly_wait(0.5)

    #bubi.By.NAME
    #b = bubi.By."NAME"
    #print(b)
    #pycall(print("2"))
    print("before find_element")
    text_box = driver.find_element(; by=bubi.By.NAME, value="my-text")
    submit_button = driver.find_element(; by=bubi.By.CSS_SELECTOR, value="button")

    text_box.send_keys("Selenium")
    submit_button.click()

    message = driver.find_element(; by=bubi.By.ID, value="message")
    text = message.text

    driver.quit()

    @test text == "Received!"
end
