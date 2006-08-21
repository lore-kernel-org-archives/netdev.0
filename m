From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 14/14] Update version ipw2200 stamp to 1.1.4
Date: Mon, 21 Aug 2006 11:39:13 +0800
Message-ID: <20060821033913.GA5451@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43695 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932593AbWHUDlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:41:08 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

d93ef0e734bdd43b02b9dbd0f030aa622ed69583
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index ea14b55..750c25d 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@
 #define VQ
 #endif
 
-#define IPW2200_VERSION "1.1.2" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.1.4" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
-- 
1.2.6
