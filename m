From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 3/5] Update version ipw2200 stamp to 1.2.0
Date: Tue, 5 Dec 2006 14:41:24 +0800
Message-ID: <20061205064124.GA18257@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43451 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758529AbWLEHJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 02:09:10 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

3bce796189a9c6f3e73a06b59817923013b38f44
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 980758c..2b29396 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@
 #define VQ
 #endif
 
-#define IPW2200_VERSION "1.1.4" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.2.0" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
-- 
1.2.6
