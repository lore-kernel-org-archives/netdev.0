From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 6/6] qlge: Bumped driver version to 1.00.00.31
Date: Fri, 29 Jun 2012 14:24:50 -0400
Message-ID: <1340994290-28832-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, Ron@linux-zupk.site,
	"Mercer <ron.mercer"@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19516 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932126Ab2F2Sln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 14:41:43 -0400
In-Reply-To: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index e81bbb7..5a8c00c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -18,7 +18,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.30.00.00-01"
+#define DRV_VERSION	"v1.00.00.31"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.7.1
