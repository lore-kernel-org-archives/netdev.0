From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 7/7] stmmac: updated the drv module version
Date: Wed, 14 Apr 2010 08:21:17 +0200
Message-ID: <1271226077-25882-7-git-send-email-peppe.cavallaro@st.com>
References: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-3-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-4-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-5-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-6-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:60553 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754270Ab0DNGVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 02:21:53 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D7C60105
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:50 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C91DC11BD
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:49 +0000 (GMT)
In-Reply-To: <1271226077-25882-6-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 1a6eb7b..ebebc64 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Jan_2010"
+#define DRV_MODULE_VERSION	"Apr_2010"
 #include <linux/stmmac.h>
 
 #include "common.h"
-- 
1.6.0.4

