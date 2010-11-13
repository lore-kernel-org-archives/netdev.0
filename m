From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] net: more Kconfig whitespace cleanup
Date: Sat, 13 Nov 2010 19:43:29 +0100
Message-ID: <1289673809-17825-1-git-send-email-phdm@macqel.be>
Cc: Philippe De Muyter <phdm@macqel.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:24540 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755814Ab0KMSoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 13:44:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

indentation for TSI108_ETH entry was too big.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>
---
 drivers/net/Kconfig |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 805cf5d..90431de 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2389,12 +2389,12 @@ config SPIDER_NET
 	  Cell Processor-Based Blades from IBM.
 
 config TSI108_ETH
-	   tristate "Tundra TSI108 gigabit Ethernet support"
-	   depends on TSI108_BRIDGE
-	   help
-	     This driver supports Tundra TSI108 gigabit Ethernet ports.
-	     To compile this driver as a module, choose M here: the module
-	     will be called tsi108_eth.
+	tristate "Tundra TSI108 gigabit Ethernet support"
+	depends on TSI108_BRIDGE
+	help
+	  This driver supports Tundra TSI108 gigabit Ethernet ports.
+	  To compile this driver as a module, choose M here: the module
+	  will be called tsi108_eth.
 
 config GELIC_NET
 	tristate "PS3 Gigabit Ethernet driver"
-- 
1.7.1

