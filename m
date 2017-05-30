From: <Woojung.Huh@microchip.com>
Subject: [PATCH v4 net-next 5/5] dsa: add maintainer of Microchip KSZ
 switches
Date: Tue, 30 May 2017 15:45:08 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA45BE@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:52268 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdE3PpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:45:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

Adding maintainer of Microchip KSZ switches.

Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 42378cf..0fcb5e75 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8479,6 +8479,16 @@ F:	drivers/media/platform/atmel/atmel-isc.c
 F:	drivers/media/platform/atmel/atmel-isc-regs.h
 F:	devicetree/bindings/media/atmel-isc.txt
 
+MICROCHIP KSZ SERIES ETHERNET SWITCH DRIVER
+M:	Woojung Huh <Woojung.Huh@microchip.com>
+M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/dsa/tag_ksz.c
+F:	drivers/net/dsa/microchip/*
+F:	include/linux/platform_data/microchip-ksz.h
+F:	Documentation/devicetree/bindings/net/dsa/ksz.txt
+
 MICROCHIP USB251XB DRIVER
 M:	Richard Leitner <richard.leitner@skidata.com>
 L:	linux-usb@vger.kernel.org
-- 
2.7.4
