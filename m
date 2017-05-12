From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net-next 5/5] dsa: add maintainer of Microchip KSZ
 switches
Date: Fri, 12 May 2017 20:08:01 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A632D5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:37048 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933166AbdELUIC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 16:08:02 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

Adding maintainer of Microchip KSZ switches.

Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 45b173a..e65e501 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8370,6 +8370,15 @@ F:	drivers/media/platform/atmel/atmel-isc.c
 F:	drivers/media/platform/atmel/atmel-isc-regs.h
 F:	devicetree/bindings/media/atmel-isc.txt
 
+MICROCHIP KSZ SERIES ETHERNET SWITCH DRIVER
+M:	Woojung Huh <Woojung.Huh@microchip.com>
+M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/dsa/microchip/*
+F:	include/linux/platform_data/microchip-ksz.h
+F:	Documentation/devicetree/bindings/net/dsa/ksz.txt
+
 MICROCHIP USB251XB DRIVER
 M:	Richard Leitner <richard.leitner@skidata.com>
 L:	linux-usb@vger.kernel.org
-- 
2.7.4
