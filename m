From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rtlwifi: rtl8723ae:fix spelling mistake: "Coexistance" -> "Coexistence"
Date: Sat, 13 May 2017 23:37:02 +0100
Message-ID: <20170513223702.19748-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        Joe Perches <joe@perches.com>,
        Christian Engelmayer <cengelma@gmx.at>,
        Arnd Bergmann <arnd@arndb.de>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50123 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756333AbdEMWhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 18:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in RT_TRACE text

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index 859c045bd37c..47e5f9003bb0 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -2313,7 +2313,7 @@ static void rtl8723e_bt_var_init(struct ieee80211_hw *hw)
 		rtlpriv->btcoexist.eeprom_bt_radio_shared;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "BT Coexistance = 0x%x\n",
+		 "BT Coexistence = 0x%x\n",
 		 rtlpriv->btcoexist.bt_coexistence);
 
 	if (rtlpriv->btcoexist.bt_coexistence) {
-- 
2.11.0
