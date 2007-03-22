From: divy@chelsio.com
Subject: [PATCH 2.6.21 5/4] cxgb3 - fix white spaces in drivers/net/Kconfig
Date: Wed, 21 Mar 2007 19:21:00 -0700
Message-ID: <20070322022100.4974.72261.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17511 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbXCVCVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 22:21:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Use tabs instead of white spaces for CHELSIO_T3 entry.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/Kconfig |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1b6459b..c3f9f59 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2372,23 +2372,23 @@ config CHELSIO_T1_NAPI
 	  when the driver is receiving lots of packets from the card.
 
 config CHELSIO_T3
-        tristate "Chelsio Communications T3 10Gb Ethernet support"
-        depends on PCI
+	tristate "Chelsio Communications T3 10Gb Ethernet support"
+	depends on PCI
 	select FW_LOADER
-        help
-          This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
-          adapters.
+	help
+	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
+	  adapters.
 
-          For general information about Chelsio and our products, visit
-          our website at <http://www.chelsio.com>.
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
 
-          For customer support, please visit our customer support page at
-          <http://www.chelsio.com/support.htm>.
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.htm>.
 
-          Please send feedback to <linux-bugs@chelsio.com>.
+	  Please send feedback to <linux-bugs@chelsio.com>.
 
-          To compile this driver as a module, choose M here: the module
-          will be called cxgb3.
+	  To compile this driver as a module, choose M here: the module
+	  will be called cxgb3.
 
 config EHEA
 	tristate "eHEA Ethernet support"
