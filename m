From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 7/7] mlx4_en: Updating driver version
Date: Mon, 17 Oct 2011 22:18:37 +0200
Message-ID: <4E9C8D9D.708@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:33276 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752453Ab1JQWYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Driver version updated to 1.5.4.2

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 89fb57c..d62c65c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -51,8 +51,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"1.5.4.1"
-#define DRV_RELDATE	"March 2011"
+#define DRV_VERSION	"1.5.4.2"
+#define DRV_RELDATE	"October 2011"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-- 
1.7.7
