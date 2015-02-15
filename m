From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 7/7] rtlwifi: Remove unused RTL_SUPPORTED_CTRL_FILTER define
Date: Sun, 15 Feb 2015 22:46:51 +0200
Message-ID: <1424033211-11696-8-git-send-email-plaes@plaes.org>
References: <1424033211-11696-1-git-send-email-plaes@plaes.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Priit Laes <plaes@plaes.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gn237.zone.eu ([217.146.67.237]:18051 "EHLO gn237.zone.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932402AbbBOUsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Feb 2015 15:48:38 -0500
In-Reply-To: <1424033211-11696-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
