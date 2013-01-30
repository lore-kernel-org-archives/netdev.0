From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 8/8] qlcnic: Bump up the version to 5.1.33
Date: Wed, 30 Jan 2013 17:47:19 -0500
Message-ID: <1359586039-19051-9-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:32834 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757241Ab3A3XId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:33 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index f71aef5..457ca8e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 1
-#define _QLCNIC_LINUX_SUBVERSION 32
-#define QLCNIC_LINUX_VERSIONID  "5.1.32"
+#define _QLCNIC_LINUX_SUBVERSION 33
+#define QLCNIC_LINUX_VERSIONID  "5.1.33"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
