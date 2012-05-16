From: "Dipinkumar" <dipin.kumar@onchiptech.com>
Subject: RT2070 usb wifi is not working with compat-wireless-3.1.1-1
Date: Wed, 16 May 2012 06:11:46 -0700
Message-ID: <20120516061146.5e5f800e16d466e1eac15b7cc2b60aca.3376d6273e.wbe@email11.secureserver.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtp11-04-2.prod.phx3.secureserver.net ([173.201.192.40]:47369
	"EHLO p3plwbeout11-04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965666Ab2EPNLs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 09:11:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
 
 I am using RT2070 usb wifi with  compat-wireless-3.1.1-1 on my imx23
embedded board.My board have linux-2.3.35.3 kernel.When kernel is
loading,giving the following error
 
 phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0x07 failed
for offset 0x0580 with error -19.
 phy0 -> rt2800_init_eeprom: Error - Invalid RT chipset detected.
 phy0 -> rt2x00lib_probe_dev: Error - Failed to allocate device.
 usbcore: registered new interface driver rt2800usb
 hub 1-0:1.0: unable to enumerate USB device on port 1
 
 can you help me to solve this issue?
 
 Regards,
 Dipin kumar
