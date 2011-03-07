From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 17/17] mlx4_en: updated driver version to 1.5.4.1
Date: Mon, 7 Mar 2011 12:18:05 +0200
Message-ID: <4D74B0DD.9010606@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:47530 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754026Ab1CGOWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 09:22:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4_en.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index edcb535..e30f609 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -49,8 +49,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"1.5.1.6"
-#define DRV_RELDATE	"August 2010"
+#define DRV_VERSION	"1.5.4.1"
+#define DRV_RELDATE	"March 2011"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-- 
1.6.0.2




