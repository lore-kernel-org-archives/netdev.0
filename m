From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: updated the drv module version
Date: Fri,  9 Apr 2010 12:24:22 +0200
Message-ID: <1270808662-7115-8-git-send-email-peppe.cavallaro@st.com>
References: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-2-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-3-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-4-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-5-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-6-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-7-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:57470 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757817Ab0DIKZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 06:25:11 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AADA112F
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:25:08 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7489C1953
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:25:08 +0000 (GMT)
In-Reply-To: <1270808662-7115-7-git-send-email-peppe.cavallaro@st.com>
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

