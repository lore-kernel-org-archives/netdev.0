From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/3] MAINTAINERS: Add Mellanox ethernet driver - mlx4_en
Date: Thu, 29 Nov 2012 19:15:31 +0200
Message-ID: <1354209333-27672-2-git-send-email-amirv@mellanox.com>
References: <1354194894-16527-1-git-send-email-amirv@mellanox.com>
 <1354209333-27672-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:47895 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752532Ab2K2RPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:15:51 -0500
In-Reply-To: <1354209333-27672-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set mlx4_en maintainer to Amir Vadai instead of Yevgeny Petrilin.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5d72dd5..67fd3de 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4822,6 +4822,13 @@ F:	Documentation/scsi/megaraid.txt
 F:	drivers/scsi/megaraid.*
 F:	drivers/scsi/megaraid/
 
+MELLANOX ETHERNET DRIVER (mlx4_en)
+M:	Amir Vadai <amirv@mellanox.com>
+L: 	netdev@vger.kernel.org
+S:	Supported
+W:	http://www.mellanox.com
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+
 MEMORY MANAGEMENT
 L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
-- 
1.7.8.2
