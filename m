From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 10/18] README.ipw2200: rename CONFIG_IPW_DEBUG to CONFIG_IPW2200_DEBUG
Date: Thu, 13 Apr 2006 17:20:21 +0800
Message-ID: <20060413092021.GA28773@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:27562 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964847AbWDMJ10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:26 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 Documentation/networking/README.ipw2200 |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

4836217fd2a5f20600b2c053a19273d75d5e6f4c
diff --git a/Documentation/networking/README.ipw2200 b/Documentation/networking/README.ipw2200
index acb30c5..c3504f5 100644
--- a/Documentation/networking/README.ipw2200
+++ b/Documentation/networking/README.ipw2200
@@ -247,8 +247,8 @@ and can set the contents via echo.  For 
 % cat /sys/bus/pci/drivers/ipw2200/debug_level
 
 Will report the current debug level of the driver's logging subsystem 
-(only available if CONFIG_IPW_DEBUG was configured when the driver was 
-built).
+(only available if CONFIG_IPW2200_DEBUG was configured when the driver
+was built).
 
 You can set the debug level via:
 
-- 
1.2.6

