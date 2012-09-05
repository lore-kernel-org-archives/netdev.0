From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 7/7] stmmac: update the driver version to Sept_2012
Date: Wed,  5 Sep 2012 17:03:52 +0200
Message-ID: <1346857432-24657-8-git-send-email-peppe.cavallaro@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:52001 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758195Ab2IEPEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:04:30 -0400
In-Reply-To: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many new feauture have been introduced in the driver:
sysFS, Rx HW watchdog... so this patch updates the
driver's version.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 577dc13..eda34c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"March_2012"
+#define DRV_MODULE_VERSION	"Sept_2012"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.7.4.4
