From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/4] stmmac: update the driver version to Feb 2012 (v2)
Date: Wed, 15 Feb 2012 11:10:40 +0100
Message-ID: <1329300640-12813-4-git-send-email-peppe.cavallaro@st.com>
References: <4F3B8101.1090509@st.com>
 <1329300640-12813-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:46907 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757062Ab2BOKLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 05:11:04 -0500
In-Reply-To: <1329300640-12813-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 6ca2aa3..0e6a749 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -21,7 +21,7 @@
 *******************************************************************************/
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"Dec_2011"
+#define DRV_MODULE_VERSION	"Feb_2012"
 #include <linux/stmmac.h>
 #include <linux/phy.h>
 #include "common.h"
-- 
1.7.4.4
