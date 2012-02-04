From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 5/5] qlge: Bumped driver version to 1.00.00.30.
Date: Fri, 3 Feb 2012 16:06:52 -0800
Message-ID: <1328314013-20458-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:7932
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754160Ab2BDAWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:22:47 -0500
In-Reply-To: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index b8478aa..5a639df 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -18,7 +18,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.29.00.00-01"
+#define DRV_VERSION	"v1.00.00.30.00.00-01"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.7.6.rc1.1.g2c162b
