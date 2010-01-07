From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 13/13] stmmac: update the driver's module version
Date: Thu,  7 Jan 2010 10:07:23 +0100
Message-ID: <1262855243-6762-13-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-10-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-11-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-12-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42583 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756362Ab0AGJHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:34 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 24FE31A8
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:30 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E13F7BE6
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
In-Reply-To: <1262855243-6762-12-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 44421d9..ba35e69 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Oct_09"
+#define DRV_MODULE_VERSION	"Jan_2010"
 #include <linux/stmmac.h>
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-- 
1.6.0.4

