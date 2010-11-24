From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/4] stmmac: update the driver version
Date: Wed, 24 Nov 2010 13:38:17 +0100
Message-ID: <1290561646-9429-4-git-send-email-peppe.cavallaro@st.com>
References: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
 <1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
 <1290561646-9429-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:38828 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab0KXMim convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 07:38:42 -0500
Received: from zeta.dmz-us.st.com (ns4.st.com [167.4.80.115])
	by beta.dmz-us.st.com (STMicroelectronics) with ESMTP id B228611F
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:39 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas3.st.com [10.75.90.18])
	by zeta.dmz-us.st.com (STMicroelectronics) with ESMTP id 205911AB
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:39 +0000 (GMT)
In-Reply-To: <1290561646-9429-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index eb258e2..5f06c47 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Apr_2010"
+#define DRV_MODULE_VERSION	"Nov_2010"
 #include <linux/platform_device.h>
 #include <linux/stmmac.h>
 
-- 
1.5.5.6
