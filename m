From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 10/10] stmmac: update the driver version March 2012
Date: Fri, 23 Mar 2012 10:08:41 +0100
Message-ID: <1332493721-28309-11-git-send-email-peppe.cavallaro@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com,
	deepak.sikri@st.com, spear-devel@list.st.com, shiraz.hashim@st.com,
	viresh.kumar@st.com, bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:34585 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757835Ab2CWJJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:09:52 -0400
In-Reply-To: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index ddd0769..9f2435c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -21,7 +21,7 @@
 *******************************************************************************/
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"Feb_2012"
+#define DRV_MODULE_VERSION	"March_2012"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.7.4.4
