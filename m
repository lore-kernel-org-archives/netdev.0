From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 12/12] qlcnic: update driver version - 5.1.30
Date: Fri, 31 Aug 2012 18:36:59 -0400
Message-ID: <1346452619-2129-13-git-send-email-sony.chacko@qlogic.com>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34759 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755164Ab2HaWyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:54:00 -0400
In-Reply-To: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 5ca57d7..5524925 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -39,8 +39,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 1
-#define _QLCNIC_LINUX_SUBVERSION 29
-#define QLCNIC_LINUX_VERSIONID  "5.1.29"
+#define _QLCNIC_LINUX_SUBVERSION 30
+#define QLCNIC_LINUX_VERSIONID  "5.1.30"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
