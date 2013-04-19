From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 3/3] qlge: Update version to 1.00.00.32.
Date: Fri, 19 Apr 2013 01:49:54 -0400
Message-ID: <1366350594-21973-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16359 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756814Ab3DSGNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 02:13:55 -0400
In-Reply-To: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index a131d7b..7e8d682 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -18,7 +18,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.31"
+#define DRV_VERSION	"v1.00.00.32"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.7.6.rc1.1.g2c162b
