From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Bump up the version to 5.1.36
Date: Fri,  8 Mar 2013 14:53:53 -0500
Message-ID: <1362772433-12045-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:46160 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756538Ab3CHURU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 15:17:20 -0500
In-Reply-To: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ba3c72f..c8b4895 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 1
-#define _QLCNIC_LINUX_SUBVERSION 35
-#define QLCNIC_LINUX_VERSIONID  "5.1.35"
+#define _QLCNIC_LINUX_SUBVERSION 36
+#define QLCNIC_LINUX_VERSIONID  "5.1.36"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.5.6
