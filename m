From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 7/7] qlcnic: Bump up the version to 5.2.39
Date: Fri, 29 Mar 2013 11:46:39 -0400
Message-ID: <1364571999-31593-8-git-send-email-rajesh.borundia@qlogic.com>
References: <1364571999-31593-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11785 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755535Ab3C2QJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 12:09:49 -0400
In-Reply-To: <1364571999-31593-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index c0b3ccf..e5af69d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,9 +37,9 @@
 #include "qlcnic_83xx_hw.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
-#define _QLCNIC_LINUX_MINOR 1
-#define _QLCNIC_LINUX_SUBVERSION 38
-#define QLCNIC_LINUX_VERSIONID  "5.1.38"
+#define _QLCNIC_LINUX_MINOR 2
+#define _QLCNIC_LINUX_SUBVERSION 39
+#define QLCNIC_LINUX_VERSIONID  "5.2.39"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.6.3.3
