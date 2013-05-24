From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 12/12] qlcnic: Update version to 5.2.43
Date: Fri, 24 May 2013 03:04:36 -0400
Message-ID: <1369379076-4718-13-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0186.outbound.messaging.microsoft.com ([213.199.154.186]:36256
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759496Ab3EXHaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:30:11 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 70681ad..03e74e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 2
-#define _QLCNIC_LINUX_SUBVERSION 42
-#define QLCNIC_LINUX_VERSIONID  "5.2.42"
+#define _QLCNIC_LINUX_SUBVERSION 43
+#define QLCNIC_LINUX_VERSIONID  "5.2.43"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.5.6
