From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/3] qlge:Version change to v1.00.00.29
Date: Thu, 30 Jun 2011 13:02:07 -0700
Message-ID: <1309464127-14797-3-git-send-email-ron.mercer@qlogic.com>
References: <1308855049.6688.19.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <ameen.rahman@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:26686
	"EHLO CH1EHSOBE010.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751097Ab1F3USx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 16:18:53 -0400
In-Reply-To: <1308855049.6688.19.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index b2c8612..ca306fd 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -16,7 +16,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.27.00.00-01"
+#define DRV_VERSION	"v1.00.00.29.00.00-01"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.6.0.2


