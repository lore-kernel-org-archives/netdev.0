From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] rtlwifi: rtl8192de: ix spelling mistake: "althougth" -> "though"
Date: Sun, 26 Feb 2017 18:52:46 +0000
Message-ID: <20170226185246.28808-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Oleg Drokin <green@linuxhacker.ru>,
        Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45902 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdBZTao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 14:30:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in RT_TRACE message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
index de98d88..dcb5d83 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
@@ -812,7 +812,7 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 	 * pathA or mac1 has to set phy0&phy1 pathA */
 	if ((content == radiob_txt) && (rfpath == RF90_PATH_A)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 " ===> althougth Path A, we load radiob.txt\n");
+			 " ===> though Path A, we load radiob.txt\n");
 		radioa_arraylen = radiob_arraylen;
 		radioa_array_table = radiob_array_table;
 	}
-- 
2.10.2
