From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 6/6] ieee80211: update version stamp to 1.1.13
Date: Thu, 13 Apr 2006 17:17:54 +0800
Message-ID: <20060413091754.GA28680@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:11213 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964836AbWDMJY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:59 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/ieee80211.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

ad81572a2505f80d22a1ceae5c055966e92df09f
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index bc6bdd6..4087dfc 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -29,7 +29,7 @@
 #include <linux/kernel.h>	/* ARRAY_SIZE */
 #include <linux/wireless.h>
 
-#define IEEE80211_VERSION "git-1.1.7"
+#define IEEE80211_VERSION "git-1.1.13"
 
 #define IEEE80211_DATA_LEN		2304
 /* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
-- 
1.2.6

