From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] MAINTAINERS: Update Mellanox's Eth NIC driver entries
Date: Tue, 17 Nov 2015 18:25:07 +0200
Message-ID: <1447777507-22326-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37387 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752301AbbKQQZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 11:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugenia (Jenny) Emantayev is replacing Amir Vadai as the 
mlx4 Ethernet driver maintainer.

Saeed Mahameed is assigned to maintain mlx5 Eth functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Thanks you so much Amir for the endless time you invested in the driver, it 
has been a pleasure to work with you, and I hope we'll keep doing so soon...

 MAINTAINERS | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4532067..902cdab 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6914,13 +6914,21 @@ F:	drivers/scsi/megaraid.*
 F:	drivers/scsi/megaraid/
 
 MELLANOX ETHERNET DRIVER (mlx4_en)
-M:	Amir Vadai <amirv@mellanox.com>
+M: 	Eugenia Emantayev <eugenia@mellanox.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 W:	http://www.mellanox.com
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
 F:	drivers/net/ethernet/mellanox/mlx4/en_*
 
+MELLANOX ETHERNET DRIVER (mlx5e)
+M:	Saeed Mahameed <saeedm@mellanox.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+W:	http://www.mellanox.com
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+F:	drivers/net/ethernet/mellanox/mlx5/core/en_*
+
 MELLANOX ETHERNET SWITCH DRIVERS
 M:	Jiri Pirko <jiri@mellanox.com>
 M:	Ido Schimmel <idosch@mellanox.com>
-- 
2.3.7
