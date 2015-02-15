From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 1/7] rtlwifi: Remove unused defines from rtl8192cu driver
Date: Sun, 15 Feb 2015 22:46:45 +0200
Message-ID: <1424033211-11696-2-git-send-email-plaes@plaes.org>
References: <1424033211-11696-1-git-send-email-plaes@plaes.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Priit Laes <plaes@plaes.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424033211-11696-1-git-send-email-plaes@plaes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
index c1e33b0..6758808 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
@@ -32,8 +32,6 @@
 
 #define H2C_RA_MASK	6
 
-#define LLT_POLLING_LLT_THRESHOLD		20
-#define LLT_POLLING_READY_TIMEOUT_COUNT		100
 #define LLT_LAST_ENTRY_OF_TX_PKT_BUFFER		255
 
 #define RX_PAGE_SIZE_REG_VALUE			PBP_128
-- 
2.3.0
