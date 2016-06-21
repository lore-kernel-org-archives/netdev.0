From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] MAINTAINERS: Update Mellanox's mlx4 Eth NIC driver entry
Date: Tue, 21 Jun 2016 16:36:06 +0300
Message-ID: <1466516166-25936-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43682 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751059AbcFUNhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 09:37:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tariq Toukan is replacing Eugenia (Jenny) Emantayev as the mlx4
Ethernet driver maintainer, thanks to Jenny and good luck to him.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2ebe195..8cffceb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7406,7 +7406,7 @@ F:	drivers/scsi/megaraid.*
 F:	drivers/scsi/megaraid/
 
 MELLANOX ETHERNET DRIVER (mlx4_en)
-M: 	Eugenia Emantayev <eugenia@mellanox.com>
+M:	Tariq Toukan <tariqt@mellanox.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 W:	http://www.mellanox.com
-- 
2.3.7
