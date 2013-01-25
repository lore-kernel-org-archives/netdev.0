From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 8/8] qlcnic: Bump up the version to 5.1.32
Date: Fri, 25 Jan 2013 15:20:41 -0500
Message-ID: <1359145241-5175-9-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43526 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752724Ab3AYUl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:29 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 84c834d..fe7da9f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,9 +37,9 @@
 #include "qlcnic_83xx_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
-#define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 31
-#define QLCNIC_LINUX_VERSIONID  "5.1.31"
+#define _QLCNIC_LINUX_MINOR 1
+#define _QLCNIC_LINUX_SUBVERSION 32
+#define QLCNIC_LINUX_VERSIONID  "5.1.32"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
