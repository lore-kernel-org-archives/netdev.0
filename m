From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Version change to v1.00.00.27
Date: Mon, 25 Oct 2010 09:17:53 -0700
Message-ID: <1288023473-31490-4-git-send-email-ron.mercer@qlogic.com>
References: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:57791 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758922Ab0JYRFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 13:05:46 -0400
In-Reply-To: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 0474d20..69c4780 100644
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

