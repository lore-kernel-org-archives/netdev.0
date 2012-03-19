From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] rtlwifi: Remove unused ETH_ADDR_LEN defines
Date: Sun, 18 Mar 2012 20:37:59 -0700
Message-ID: <b1302b9179a9fb95c28201fdc8ca1208fba51644.1332128181.git.joe@perches.com>
References: <cover.1332128181.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35797 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030205Ab2CSDir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 23:38:47 -0400
In-Reply-To: <cover.1332128181.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h |    1 -
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
index 43806d9..e4d738f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
@@ -1190,7 +1190,6 @@
 
 #define USB_AGG_EN				BIT(3)
 
-#define MAC_ADDR_LEN				6
 #define LAST_ENTRY_OF_TX_PKT_BUFFER		255
 
 #define POLLING_LLT_THRESHOLD			20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
index 9bc4623..ebb1d5f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
@@ -998,7 +998,6 @@
 #define SCR_RXBCUSEDK				BIT(7)
 
 /* General definitions */
-#define MAC_ADDR_LEN				6
 #define LAST_ENTRY_OF_TX_PKT_BUFFER		255
 #define LAST_ENTRY_OF_TX_PKT_BUFFER_DUAL_MAC	127
 
-- 
1.7.8.111.gad25c.dirty
