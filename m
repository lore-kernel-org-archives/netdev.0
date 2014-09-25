From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v5 3/3] MAINTAINER: net: Add TI NETCP Ethernet driver entry
Date: Thu, 25 Sep 2014 13:48:37 -0400
Message-ID: <1411667317-1163-4-git-send-email-santosh.shilimkar@ti.com>
References: <1411667317-1163-1-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <robh+dt@kernel.org>,
	<grant.likely@linaro.org>, <devicetree@vger.kernel.org>,
	<sandeep_n@ti.com>, <joe@perches.com>,
	Santosh Shilimkar <santosh.shilimkar@ti.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:49702 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130AbaIYRtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 13:49:12 -0400
In-Reply-To: <1411667317-1163-1-git-send-email-santosh.shilimkar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Nair <sandeep_n@ti.com>

Signed-off-by: Sandeep Nair <sandeep_n@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index aefa948..4821dcf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9117,6 +9117,13 @@ F:	drivers/power/lp8788-charger.c
 F:	drivers/regulator/lp8788-*.c
 F:	include/linux/mfd/lp8788*.h
 
+TI NETCP ETHERNET DRIVER
+M:	Sandeep Nair <sandeep_n@ti.com>
+M:	Santosh Shilimkar <santosh.shilimkar@ti.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/ti/netcp*
+
 TI TWL4030 SERIES SOC CODEC DRIVER
 M:	Peter Ujfalusi <peter.ujfalusi@ti.com>
 L:	alsa-devel@alsa-project.org (moderated for non-subscribers)
-- 
1.7.9.5
