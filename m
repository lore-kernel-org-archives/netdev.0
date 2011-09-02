From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 9/9] stmmac: update the driver version (Aug_2011) (v3)
Date: Fri,  2 Sep 2011 09:51:43 +0200
Message-ID: <1314949903-26137-10-git-send-email-peppe.cavallaro@st.com>
References: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:43723 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757973Ab1IBHwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 03:52:54 -0400
In-Reply-To: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index c3a2da7..1434bdb 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"July_2011"
+#define DRV_MODULE_VERSION	"Aug_2011"
 #include <linux/stmmac.h>
 
 #include "common.h"
-- 
1.7.4.4
