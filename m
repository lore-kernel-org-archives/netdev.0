From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 1/6] net: phy: broadcom: add bcm54220 phy ID
Date: Wed, 19 Aug 2015 13:33:59 +0800
Message-ID: <1439962444-27486-2-git-send-email-b38611@freescale.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<b38611@freescale.com>
To: <shawnguo@kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0137.outbound.protection.outlook.com ([207.46.100.137]:11616
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751292AbbHSFei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 01:34:38 -0400
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bcm54220 phy ID entry.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 include/linux/brcmphy.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 697ca77..20bed15 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -16,6 +16,7 @@
 #define PHY_ID_BCM5482			0x0143bcb0
 #define PHY_ID_BCM5411			0x00206070
 #define PHY_ID_BCM5421			0x002060e0
+#define PHY_ID_BCM54220			0x600d8589
 #define PHY_ID_BCM5464			0x002060b0
 #define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM54616S		0x03625d10
-- 
1.9.1
