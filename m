From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/4] stmmac: update the version (V2)
Date: Wed, 20 Jul 2011 12:05:21 +0200
Message-ID: <1311156324-23928-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:55418 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317Ab1GTKeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 06:34:00 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5AD4EB1
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:06:51 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1CC121801
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:06:51 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 2b076b3..92c1d73 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Nov_2010"
+#define DRV_MODULE_VERSION	"July_2011"
 #include <linux/stmmac.h>
 
 #include "common.h"
-- 
1.7.4.4

