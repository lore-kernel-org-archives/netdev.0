From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v3 7/7] rtlwifi: Remove unused RTL_SUPPORTED_CTRL_FILTER define
Date: Mon, 16 Feb 2015 15:01:57 +0200
Message-ID: <1424091717-13212-5-git-send-email-plaes@plaes.org>
References: <1424091600-13121-1-git-send-email-plaes@plaes.org>
 <1424091717-13212-1-git-send-email-plaes@plaes.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Priit Laes <plaes@plaes.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424091717-13212-1-git-send-email-plaes@plaes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/core.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index 7b64e34..82733c6 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -33,8 +33,6 @@
 	FIF_FCSFAIL | \
 	FIF_BCN_PRBRESP_PROMISC)
 
-#define RTL_SUPPORTED_CTRL_FILTER	0xFF
-
 #define DM_DIG_THRESH_HIGH		40
 #define DM_DIG_THRESH_LOW		35
 #define DM_FALSEALARM_THRESH_LOW	400
-- 
2.3.0
