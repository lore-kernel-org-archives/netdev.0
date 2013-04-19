From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 8/8] qlcnic: Update version to 5.2.41
Date: Fri, 19 Apr 2013 13:01:15 -0400
Message-ID: <1366390875-24570-9-git-send-email-rajesh.borundia@qlogic.com>
References: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34515 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752590Ab3DSRZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 13:25:06 -0400
In-Reply-To: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 86eaa68..8d02dd7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 2
-#define _QLCNIC_LINUX_SUBVERSION 40
-#define QLCNIC_LINUX_VERSIONID  "5.2.40"
+#define _QLCNIC_LINUX_SUBVERSION 41
+#define QLCNIC_LINUX_VERSIONID  "5.2.41"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.6.3.3
