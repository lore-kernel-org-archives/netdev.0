From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/3] smsc95xx: Add maintainer
Date: Fri, 2 Sep 2016 20:34:19 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4091009A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:38488 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753958AbcIBUeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:34:20 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add Microchip Linux Driver Support as maintainer
because this driver is maintaining by Microchip.

Signed-off-by: Woojung Huh <Woojung.huh@gmail.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 58b5029..324e3b8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12279,6 +12279,7 @@ F:	drivers/net/usb/smsc75xx.*
 
 USB SMSC95XX ETHERNET DRIVER
 M:	Steve Glendinning <steve.glendinning@shawell.net>
+M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/usb/smsc95xx.*
-- 
2.7.4
