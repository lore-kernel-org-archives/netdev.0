From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] cfg80211: Use tabs for identation
Date: Fri, 25 Aug 2017 03:32:08 +0530
Message-ID: <1503612128-28782-1-git-send-email-himanshujha199640@gmail.com>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed whitespaces and added necessary tabs conforming to coding style.
Issue found using checkpatch.pl

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 net/wireless/chan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index b8aa5a7..13c95e5 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -984,9 +984,9 @@ int cfg80211_set_monitor_channel(struct cfg80211_registered_device *rdev,
 
 void
 cfg80211_get_chan_state(struct wireless_dev *wdev,
-		        struct ieee80211_channel **chan,
-		        enum cfg80211_chan_mode *chanmode,
-		        u8 *radar_detect)
+			struct ieee80211_channel **chan,
+			enum cfg80211_chan_mode *chanmode,
+			u8 *radar_detect)
 {
 	int ret;
 
-- 
2.7.4
