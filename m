From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 10/10] stmmac: update the driver version March 2012
Date: Wed,  4 Apr 2012 16:33:28 +0200
Message-ID: <1333550008-16500-11-git-send-email-peppe.cavallaro@st.com>
References: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, deepak.sikri@st.com, spear-devel@list.st.com,
	shiraz.hashim@st.com, viresh.kumar@st.com,
	srinivas.kandagatla@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38444 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756728Ab2DDOej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:34:39 -0400
In-Reply-To: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
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
