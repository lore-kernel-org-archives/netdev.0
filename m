From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/3] qlge:Version change to v1.00.00.29
Date: Thu, 23 Jun 2011 10:52:24 -0700
Message-ID: <1308851544-25719-3-git-send-email-ron.mercer@qlogic.com>
References: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <ameen.rahman@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:30500
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933000Ab1FWSLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:11:16 -0400
In-Reply-To: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
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


