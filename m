From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/2] qlge: Version change to v1.00.00.27
Date: Wed, 10 Nov 2010 11:29:46 -0800
Message-ID: <1289417386-28384-2-git-send-email-ron.mercer@qlogic.com>
References: <20101108.134932.116391208.davem@davemloft.net>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:40681 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756635Ab0KJTmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 14:42:00 -0500
In-Reply-To: <20101108.134932.116391208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index b1e8151..bdb8fe8 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -16,7 +16,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.25.00.00-01"
+#define DRV_VERSION	"v1.00.00.27.00.00-01"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.6.0.2

