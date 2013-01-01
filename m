From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V1 14/14] qlcnic: update driver version
Date: Tue,  1 Jan 2013 08:20:30 -0500
Message-ID: <1357046430-31437-15-git-send-email-sony.chacko@qlogic.com>
References: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	"Signed-off-by: Sony Chacko" <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:51506 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752352Ab3AANkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 08:40:22 -0500
In-Reply-To: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 471982c..893cbe8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 30
-#define QLCNIC_LINUX_VERSIONID  "5.0.30"
+#define _QLCNIC_LINUX_SUBVERSION 31
+#define QLCNIC_LINUX_VERSIONID  "5.1.31"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.1
