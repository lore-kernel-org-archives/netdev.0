From: <Bryan.Whitehead@microchip.com>
Subject: [PATCH net-next 3/3] Add LAN743X to MAINTAINER list
Date: Fri, 11 Aug 2017 19:48:05 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264406F6053@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:18454 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753711AbdHKTsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 15:48:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan Whitehead <Bryan.Whitehead@microchip.com>

Add LAN743X to MAINTAINER list

Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2db0f8c..3216348 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8749,6 +8749,13 @@ F:	drivers/net/dsa/microchip/*
 F:	include/linux/platform_data/microchip-ksz.h
 F:	Documentation/devicetree/bindings/net/dsa/ksz.txt
 
+MICROCHIP LAN743X ETHERNET DRIVER
+M:	Bryan Whitehead <bryan.whitehead@microchip.com>
+M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/microchip/lan743x.*
+
 MICROCHIP USB251XB DRIVER
 M:	Richard Leitner <richard.leitner@skidata.com>
 L:	linux-usb@vger.kernel.org
-- 
2.7.4
