From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 4/4] MAINTAINERS: Add LAN78XX entry
Date: Thu, 25 Feb 2016 23:33:16 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404B83EA@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:17016 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752665AbcBYXdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:33:17 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add maintainers for Microchip LAN78XX.
UNGLinuxDriver@microchip.com is alias email which goes to current
developers work for Microchip Network related products.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 27393cf..12b764f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11332,6 +11332,13 @@ S:	Maintained
 F:	drivers/usb/host/isp116x*
 F:	include/linux/usb/isp116x.h
 
+USB LAN78XX ETHERNET DRIVER
+M:	Woojung Huh <woojung.huh@microchip.com>
+M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/usb/lan78xx.*
+
 USB MASS STORAGE DRIVER
 M:	Matthew Dharm <mdharm-usb@one-eyed-alien.net>
 L:	linux-usb@vger.kernel.org
-- 
2.7.0
