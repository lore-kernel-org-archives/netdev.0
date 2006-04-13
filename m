From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 13/18] ipw2200: update version stamp to 1.1.2
Date: Thu, 13 Apr 2006 17:20:40 +0800
Message-ID: <20060413092040.GA28794@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:34253 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964851AbWDMJ1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:47 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 Documentation/networking/README.ipw2200 |    6 +++---
 drivers/net/wireless/ipw2200.c          |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

dd0f5de1aff491fb0358b7eaf7d22e907fa1e5ee
diff --git a/Documentation/networking/README.ipw2200 b/Documentation/networking/README.ipw2200
index c3504f5..4f2a40f 100644
--- a/Documentation/networking/README.ipw2200
+++ b/Documentation/networking/README.ipw2200
@@ -14,8 +14,8 @@ Copyright (C) 2004-2006, Intel Corporati
 
 README.ipw2200
 
-Version: 1.0.8
-Date   : October 20, 2005
+Version: 1.1.2
+Date   : March 30, 2006
 
 
 Index
@@ -103,7 +103,7 @@ file.
 
 1.1. Overview of Features
 -----------------------------------------------
-The current release (1.0.8) supports the following features:
+The current release (1.1.2) supports the following features:
 
 + BSS mode (Infrastructure, Managed)
 + IBSS mode (Ad-Hoc)
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 8b20d6c..67e4150 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@
 #define VQ
 #endif
 
-#define IPW2200_VERSION "1.1.1" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.1.2" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
-- 
1.2.6

