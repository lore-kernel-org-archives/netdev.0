From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mwifiex: fix a comment typo
Date: Sun,  4 Oct 2015 16:46:55 +0800
Message-ID: <53a87c6aae6bae712c079bf17ed27d0f1b381016.1443948331.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just fix a typo in the code comment.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/wireless/mwifiex/cfg80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 30cbafb..b7ac45f 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2374,7 +2374,7 @@ mwifiex_cfg80211_leave_ibss(struct wiphy *wiphy, struct net_device *dev)
  * CFG802.11 operation handler for scan request.
  *
  * This function issues a scan request to the firmware based upon
- * the user specified scan configuration. On successfull completion,
+ * the user specified scan configuration. On successful completion,
  * it also informs the results.
  */
 static int
-- 
2.5.0
