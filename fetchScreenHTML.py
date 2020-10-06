from selenium import webdriver
from selenium.webdriver.common.proxy import *
from selenium.webdriver.common.keys import Keys
import urllib2
import urlparse
import socket
from xvfbwrapper import Xvfb #virtual display so can run this stuff headless on Bunk

import codecs

def fetchScreenHTML(url,dirpath=""):
	vdisplay = Xvfb()
	vdisplay.start()

	timeout=15
	socket.setdefaulttimeout(timeout)

	driver = webdriver.Firefox()

	try:
		driver.get("http://"+url)
		driver.save_screenshot('%s%s.png'%(dirpath,url))
		htmlsrc = driver.page_source
		f = codecs.open('%s%s.html'%(dirpath,url),encoding='utf-8',mode='w')
		f.write(htmlsrc)
		f.close()
		driver.quit()
	except:
		print 'error on %s' %url
		driver.quit()
	vdisplay.stop()

import sys
if __name__=="__main__":
	if len(sys.argv)==2:
		for line in open(sys.argv[1]):
			print line.strip()
			fetchScreenHTML(line.strip())
	elif len(sys.argv)==3:
		for line in open(sys.argv[1]):
			fetchScreenHTML(line.strip(),sys.argv[2])
