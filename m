From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] trivial: remove duplicate "different" from comment
Date: Tue, 11 Aug 2009 11:18:42 -0300
Message-ID: <1250000322-19354-1-git-send-email-cascardo@holoscopio.com>
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linville@tuxdriver.com, lrodriguez@atheros.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754807AbZHKOTK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 net/wireless/reg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index fc7a484..f256dff 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1424,7 +1424,7 @@ static int ignore_request(struct wiphy *wiphy,
 			if (last_wiphy != wiphy) {
 				/*
 				 * Two cards with two APs claiming different
-				 * different Country IE alpha2s. We could
+				 * Country IE alpha2s. We could
 				 * intersect them, but that seems unlikely
 				 * to be correct. Reject second one for now.
 				 */
-- 
1.6.3.3
