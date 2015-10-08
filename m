From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 5/5] MAINTAINERS: Update mlx4_en driver entry
Date: Thu,  8 Oct 2015 15:26:19 +0300
Message-ID: <1444307179-16105-6-git-send-email-ogerlitz@mellanox.com>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57497 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757155AbbJHM1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:27:12 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Remove Ido Shamay as co-maintainer for the mlx4 Ethernet driver,
as he no longer works for Mellanox.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 797236b..4bdc1bd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6778,7 +6778,6 @@ F:	drivers/scsi/megaraid/
 
 MELLANOX ETHERNET DRIVER (mlx4_en)
 M:	Amir Vadai <amirv@mellanox.com>
-M:	Ido Shamay <idos@mellanox.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 W:	http://www.mellanox.com
-- 
2.3.7
