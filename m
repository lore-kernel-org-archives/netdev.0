From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 6/6] IB/mlx5: Bump driver version
Date: Tue, 23 May 2017 14:44:04 +0300
Message-ID: <20170523114404.20387-7-saeedm@mellanox.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170523114404.20387-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Remove date and bump version for mlx5_ib driver.

Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index b6991204e5df..42defaa0d6c6 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -60,8 +60,7 @@
 #include "cmd.h"
 
 #define DRIVER_NAME "mlx5_ib"
-#define DRIVER_VERSION "2.2-1"
-#define DRIVER_RELDATE	"Feb 2014"
+#define DRIVER_VERSION "5.0-0"
 
 MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
 MODULE_DESCRIPTION("Mellanox Connect-IB HCA IB driver");
@@ -70,7 +69,7 @@ MODULE_VERSION(DRIVER_VERSION);
 
 static char mlx5_version[] =
 	DRIVER_NAME ": Mellanox Connect-IB Infiniband driver v"
-	DRIVER_VERSION " (" DRIVER_RELDATE ")\n";
+	DRIVER_VERSION "\n";
 
 enum {
 	MLX5_ATOMIC_SIZE_QP_8BYTES = 1 << 3,
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
