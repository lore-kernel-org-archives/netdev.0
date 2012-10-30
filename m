From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v4 21/21] qlcnic: update driver version - 5.1.30
Date: Mon, 29 Oct 2012 20:14:52 -0400
Message-ID: <1351556092-16417-22-git-send-email-sony.chacko@qlogic.com>
References: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:39917 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755983Ab2J3AeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 20:34:13 -0400
In-Reply-To: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 4014cb3..e9ed6aa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,9 +37,10 @@
 #include "qlcnic_83xx_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
-#define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 29
-#define QLCNIC_LINUX_VERSIONID  "5.0.29"
+#define _QLCNIC_LINUX_MINOR 1
+#define _QLCNIC_LINUX_SUBVERSION 30
+#define QLCNIC_LINUX_VERSIONID  "5.1.30"
+
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
