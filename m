From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH NEXT] rtlwifi: Eliminate two empty routines
Date: Sun, 27 Jan 2013 16:40:34 -0600
Message-ID: <1359326434-16093-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rc.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rc.c b/drivers/net/wireless/rtlwifi/rc.c
index c1e065f..204f46c 100644
--- a/drivers/net/wireless/rtlwifi/rc.c
+++ b/drivers/net/wireless/rtlwifi/rc.c
@@ -217,19 +217,6 @@ static void rtl_tx_status(void *ppriv,
 	}
 }
 
-static void rtl_rate_init(void *ppriv,
-			  struct ieee80211_supported_band *sband,
-			  struct ieee80211_sta *sta, void *priv_sta)
-{
-}
-
-static void rtl_rate_update(void *ppriv,
-			    struct ieee80211_supported_band *sband,
-			    struct ieee80211_sta *sta, void *priv_sta,
-			    u32 changed)
-{
-}
