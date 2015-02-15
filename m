From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 4/7] rtlwifi: Remove unused defines from cam.h
Date: Sun, 15 Feb 2015 22:46:48 +0200
Message-ID: <1424033211-11696-5-git-send-email-plaes@plaes.org>
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
 drivers/net/wireless/rtlwifi/cam.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.h b/drivers/net/wireless/rtlwifi/cam.h
index 3550808..e2e647d 100644
--- a/drivers/net/wireless/rtlwifi/cam.h
+++ b/drivers/net/wireless/rtlwifi/cam.h
@@ -28,13 +28,11 @@
 
 #define CAM_CONTENT_COUNT				8
 
-#define CFG_DEFAULT_KEY					BIT(5)
 #define CFG_VALID					BIT(15)
 
 #define PAIRWISE_KEYIDX					0
 #define CAM_PAIRWISE_KEY_POSITION			4
 
-#define	CAM_CONFIG_USEDK				1
 #define	CAM_CONFIG_NO_USEDK				0
 
 void rtl_cam_reset_all_entry(struct ieee80211_hw *hw);
-- 
2.3.0
