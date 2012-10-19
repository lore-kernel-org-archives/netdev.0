From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V2 20/20] qlcnic: update driver version - 5.1.30
Date: Fri, 19 Oct 2012 04:37:38 -0400
Message-ID: <1350635858-27549-21-git-send-email-sony.chacko@qlogic.com>
References: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25360 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758022Ab2JSI4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 04:56:38 -0400
In-Reply-To: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 32212ee..d208674 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,9 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 29
-#define QLCNIC_LINUX_VERSIONID  "5.0.29"
+#define _QLCNIC_LINUX_SUBVERSION 30
+#define QLCNIC_LINUX_VERSIONID  "5.1.30"
+
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
