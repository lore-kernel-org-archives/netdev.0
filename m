From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 7/7] stmmac: update the driver version to August_2012
Date: Mon,  3 Sep 2012 09:47:02 +0200
Message-ID: <1346658422-1925-8-git-send-email-peppe.cavallaro@st.com>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:39297 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755598Ab2ICHrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:47:33 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 05AF81D7
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:31 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C40132B9B
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:31 +0000 (GMT)
In-Reply-To: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many new feautures have been introduced in the driver:
sysFS, Rx HW watchdog... so this patch updates the
driver's version.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 05f17184..ad95f26 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"March_2012"
+#define DRV_MODULE_VERSION	"August_2012"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.7.4.4
