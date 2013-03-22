From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Bump up the version to 5.1.38
Date: Fri, 22 Mar 2013 11:57:57 -0400
Message-ID: <1363967877-16812-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33795 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933862Ab3CVQVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:21:23 -0400
In-Reply-To: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 1577799..72bbba0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 1
-#define _QLCNIC_LINUX_SUBVERSION 37
-#define QLCNIC_LINUX_VERSIONID  "5.1.37"
+#define _QLCNIC_LINUX_SUBVERSION 38
+#define QLCNIC_LINUX_VERSIONID  "5.1.38"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.5.6
