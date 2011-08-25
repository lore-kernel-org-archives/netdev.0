From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 9/9] stmmac: update the driver version (Aug_2011)
Date: Thu, 25 Aug 2011 10:00:29 +0200
Message-ID: <1314259229-13767-10-git-send-email-peppe.cavallaro@st.com>
References: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:45773 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751879Ab1HYIBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:01:40 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DE205113
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:01:38 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AA66916B2
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:01:38 +0000 (GMT)
In-Reply-To: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 3461676..6bc0d0c 100644
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
