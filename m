From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 3/3] MAINTAINER: net: Add TI NETCP Ethernet driver entry
Date: Fri, 15 Aug 2014 11:12:42 -0400
Message-ID: <1408115562-22487-4-git-send-email-santosh.shilimkar@ti.com>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <robh+dt@kernel.org>,
	<grant.likely@linaro.org>, <devicetree@vger.kernel.org>,
	<sandeep_n@ti.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41429 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbaHOPNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 11:13:33 -0400
In-Reply-To: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Nair <sandeep_n@ti.com>

Signed-off-by: Sandeep Nair <sandeep_n@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 134483f..7b1c41d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9038,6 +9038,12 @@ F:	drivers/power/lp8788-charger.c
 F:	drivers/regulator/lp8788-*.c
 F:	include/linux/mfd/lp8788*.h
 
+TI NETCP ETHERNET DRIVER
+M:	Sandeep Nair <sandeep_n@ti.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/ti/netcp*
+
 TI TWL4030 SERIES SOC CODEC DRIVER
 M:	Peter Ujfalusi <peter.ujfalusi@ti.com>
 L:	alsa-devel@alsa-project.org (moderated for non-subscribers)
-- 
1.7.9.5
