From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 8/8] mlx4_en: Updated driver version
Date: Tue, 02 Jun 2009 12:29:42 +0300
Message-ID: <4A24F106.3030308@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50366 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750751AbZFBIi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:38:59 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4_en.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 4de8db0..f5909c7 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -49,8 +49,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"1.4.0"
-#define DRV_RELDATE	"Sep 2008"
+#define DRV_VERSION	"1.4.1.1
+#define DRV_RELDATE	"June 2009"
 
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
-- 
1.6.0


