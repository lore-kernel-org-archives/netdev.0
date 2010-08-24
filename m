From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 14/14] mlx4_en: updated driver version
Date: Tue, 24 Aug 2010 16:46:49 +0300
Message-ID: <4C73CD49.8070808@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50200 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660Ab0HXNqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4_en.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 7d4ddb9..ce8e233 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -49,8 +49,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"1.4.1.1"
-#define DRV_RELDATE	"June 2009"
+#define DRV_VERSION	"1.5.1.6"
+#define DRV_RELDATE	"August 2010"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-- 
1.6.1.3


