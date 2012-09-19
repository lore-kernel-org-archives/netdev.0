From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 19/19] qlcnic: update driver version - 5.1.30
Date: Wed, 19 Sep 2012 19:46:13 -0400
Message-ID: <1348098373-20745-20-git-send-email-sony.chacko@qlogic.com>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58704 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753112Ab2ITAMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 20:12:18 -0400
In-Reply-To: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index aaf039b..2007421 100644
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
