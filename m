From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v2 1/3] MAINTAINERS: Add Mellanox ethernet driver - mlx4_en
Date: Sun,  2 Dec 2012 15:49:21 +0200
Message-ID: <1354456163-10497-2-git-send-email-amirv@mellanox.com>
References: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:37176 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751506Ab2LBNtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 08:49:42 -0500
In-Reply-To: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set mlx4_en maintainer to Amir Vadai instead of Yevgeny Petrilin.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
---
 MAINTAINERS |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5d72dd5..3c6e8cd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4822,6 +4822,14 @@ F:	Documentation/scsi/megaraid.txt
 F:	drivers/scsi/megaraid.*
 F:	drivers/scsi/megaraid/
 
+MELLANOX ETHERNET DRIVER (mlx4_en)
+M:	Amir Vadai <amirv@mellanox.com>
+L: 	netdev@vger.kernel.org
+S:	Supported
+W:	http://www.mellanox.com
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+F:	drivers/net/ethernet/mellanox/mlx4/en_*
+
 MEMORY MANAGEMENT
 L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
-- 
1.7.8.2
