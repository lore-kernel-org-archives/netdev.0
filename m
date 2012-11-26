From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 6/6] stmmac: update the driver version to Nov_2012
Date: Mon, 26 Nov 2012 10:10:46 +0100
Message-ID: <1353921046-5121-7-git-send-email-peppe.cavallaro@st.com>
References: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:42437 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754539Ab2KZJLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:11:50 -0500
In-Reply-To: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many new feauture have been introduced in the driver:
ethtool coalesce options, Rx HW watchdog... so this patch updates the
driver's version.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index fe0535c..023a4fb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"March_2012"
+#define DRV_MODULE_VERSION	"Nov_2012"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.7.4.4
