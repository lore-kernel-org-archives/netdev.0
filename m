From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/2] MAINTAINERS: Assign new maintainers to Mellanox mlx5 core and IB drivers
Date: Wed, 23 Dec 2015 18:30:57 +0200
Message-ID: <1450888258-19557-2-git-send-email-ogerlitz@mellanox.com>
References: <1450888258-19557-1-git-send-email-ogerlitz@mellanox.com>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450888258-19557-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Matan and Leon step in as co-maintainers to replace Eli Cohen
who wrote and maintained the core and IB drivers.

Signed-off-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 MAINTAINERS | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c6b78b0..c7586a5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7057,27 +7057,26 @@ W:	http://linuxtv.org
 S:	Odd Fixes
 F:	drivers/media/radio/radio-miropcm20*
 
-Mellanox MLX5 core VPI driver
-M:	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+MELLANOX MLX5 core VPI driver
+M:	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+M:	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
 L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://www.mellanox.com
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
-Q:	http://patchwork.kernel.org/project/linux-rdma/list/
-T:	git git://openfabrics.org/~eli/connect-ib.git
 S:	Supported
 F:	drivers/net/ethernet/mellanox/mlx5/core/
 F:	include/linux/mlx5/
 
-Mellanox MLX5 IB driver
-M:	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+MELLANOX MLX5 IB driver
+M:	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+M:	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
 L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://www.mellanox.com
 Q:	http://patchwork.kernel.org/project/linux-rdma/list/
-T:	git git://openfabrics.org/~eli/connect-ib.git
 S:	Supported
-F:	include/linux/mlx5/
 F:	drivers/infiniband/hw/mlx5/
+F:	include/linux/mlx5/
 
 MELEXIS MLX90614 DRIVER
 M:	Crt Mori <cmo-fc6wVz46lShBDgjK7y7TUQ@public.gmane.org>
-- 
2.3.7

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
