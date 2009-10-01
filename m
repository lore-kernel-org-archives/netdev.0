From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 7/7] mlx4_en: Updated driver version and date
Date: Thu, 01 Oct 2009 16:34:23 +0200
Message-ID: <4AC4BDEF.50004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:48855 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756438AbZJALgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:36:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4_en.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 8655624..89ca376 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -50,8 +50,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"1.4.1.1"
-#define DRV_RELDATE	"June 2009"
+#define DRV_VERSION	"1.4.2.1"
+#define DRV_RELDATE	"Oct 2009"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-- 
1.6.1.3


