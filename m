From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/3] stmmac: update the version
Date: Tue, 19 Jul 2011 10:38:03 +0200
Message-ID: <1311064684-20246-2-git-send-email-peppe.cavallaro@st.com>
References: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:50955 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752386Ab1GSIi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 04:38:56 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 86F281BB
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 08:38:53 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0BF7427B8
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 08:38:53 +0000 (GMT)
In-Reply-To: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index c2b6b8e..0b17429 100644
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

