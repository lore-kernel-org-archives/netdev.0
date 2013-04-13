From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 9/9] qlcnic: Bump up the version to 5.2.41
Date: Sat, 13 Apr 2013 13:28:34 -0400
Message-ID: <1365874114-6759-10-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:46056 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752859Ab3DMRxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:53:12 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 2902a15..224a089 100644
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
1.5.6
