From: Joe Perches <joe@perches.com>
Subject: [PATCH] amd8111e: trivial typo spelling: Negotitate -> Negotiate
Date: Mon, 02 May 2011 12:59:29 -0700
Message-ID: <1304366369.7792.45.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1128 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab1EBT7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2011 15:59:30 -0400
Received: from [192.168.1.162] (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id 4747524368
	for <netdev@vger.kernel.org>; Mon,  2 May 2011 12:59:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/amd8111e.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 88495c4..241b185 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -106,7 +106,7 @@ MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version "M
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 module_param_array(speed_duplex, int, NULL, 0);
-MODULE_PARM_DESC(speed_duplex, "Set device speed and duplex modes, 0: Auto Negotitate, 1: 10Mbps Half Duplex, 2: 10Mbps Full Duplex, 3: 100Mbps Half Duplex, 4: 100Mbps Full Duplex");
+MODULE_PARM_DESC(speed_duplex, "Set device speed and duplex modes, 0: Auto Negotiate, 1: 10Mbps Half Duplex, 2: 10Mbps Full Duplex, 3: 100Mbps Half Duplex, 4: 100Mbps Full Duplex");
 module_param_array(coalesce, bool, NULL, 0);
 MODULE_PARM_DESC(coalesce, "Enable or Disable interrupt coalescing, 1: Enable, 0: Disable");
 module_param_array(dynamic_ipg, bool, NULL, 0);


