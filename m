From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 4/4] qlcnic: Bump up the version to 5.2.40
Date: Tue,  2 Apr 2013 11:34:43 -0400
Message-ID: <1364916883-10109-5-git-send-email-rajesh.borundia@qlogic.com>
References: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:3783 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761427Ab3DBP5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:57:51 -0400
In-Reply-To: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index e5af69d..ef55718 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 2
-#define _QLCNIC_LINUX_SUBVERSION 39
-#define QLCNIC_LINUX_VERSIONID  "5.2.39"
+#define _QLCNIC_LINUX_SUBVERSION 40
+#define QLCNIC_LINUX_VERSIONID  "5.2.40"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.6.3.3
