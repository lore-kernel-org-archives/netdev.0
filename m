From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/4] qlge: Change version to v1.00.00.23.00.00-01.
Date: Wed, 11 Nov 2009 14:54:06 -0800
Message-ID: <1257980046-2420-5-git-send-email-ron.mercer@qlogic.com>
References: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24232 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759510AbZKKXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 18:00:36 -0500
In-Reply-To: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 1f59f05..862c1aa 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -16,7 +16,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00-b3"
+#define DRV_VERSION	"v1.00.00.23.00.00-01"
 
 #define PFX "qlge: "
 #define QPRINTK(qdev, nlevel, klevel, fmt, args...)     \
-- 
1.6.0.2

