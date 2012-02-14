From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/4] stmmac: update the driver version to Feb 2012
Date: Tue, 14 Feb 2012 08:11:48 +0100
Message-ID: <1329203508-19612-5-git-send-email-peppe.cavallaro@st.com>
References: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:43119 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754896Ab2BNHMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 02:12:24 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E5B34CD
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:22 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B401117E5
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:22 +0000 (GMT)
In-Reply-To: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
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
+#define DRV_MODULE_VERSION	"Feb_2011"
 #include <linux/stmmac.h>
 #include <linux/phy.h>
 #include "common.h"
-- 
1.7.4.4
