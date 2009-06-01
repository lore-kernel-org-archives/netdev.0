From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] MAINTAINERS: take maintainership of the cpmac Ethernet driver
Date: Mon, 1 Jun 2009 09:37:54 +0200
Message-ID: <200906010937.55673.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:37186 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbZFAHh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 03:37:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, David,

Not sure who is going to take this patch, therefore I am sending it
to both of you. Thanks.
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] MAINTAINERS: take maintainership of the cpmac Ethernet driver

This patch adds me as the maintainer of the CPMAC (AR7)
Ethernet driver.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/MAINTAINERS b/MAINTAINERS
index 77f277e..e18baa4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1545,6 +1545,13 @@ W:	http://www.fi.muni.cz/~kas/cosa/
 S:	Maintained
 F:	drivers/net/wan/cosa*
 
+CPMAC ETHERNET DRIVER
+P:	Florian Fainelli
+M:	florian@openwrt.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/cpmac.c
+
 CPU FREQUENCY DRIVERS
 P:	Dave Jones
 M:	davej@redhat.com
