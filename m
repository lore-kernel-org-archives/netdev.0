From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 6/7] rtlwifi: Remove unused defines from efuse.h
Date: Sun, 15 Feb 2015 22:46:50 +0200
Message-ID: <1424033211-11696-7-git-send-email-plaes@plaes.org>
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
 drivers/net/wireless/rtlwifi/efuse.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/efuse.h b/drivers/net/wireless/rtlwifi/efuse.h
index fdab824..be02e78 100644
--- a/drivers/net/wireless/rtlwifi/efuse.h
+++ b/drivers/net/wireless/rtlwifi/efuse.h
@@ -40,12 +40,6 @@
 #define PG_STATE_WORD_3			0x10
 #define PG_STATE_DATA			0x20
 
-#define PG_SWBYTE_H			0x01
-#define PG_SWBYTE_L			0x02
-
-#define _POWERON_DELAY_
-#define _PRE_EXECUTE_READ_CMD_
-
 #define EFUSE_REPEAT_THRESHOLD_		3
 #define EFUSE_ERROE_HANDLE		1
 
-- 
2.3.0
