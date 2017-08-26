From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] sni_82596: Add Thomas' email address to driver.
Date: Sat, 26 Aug 2017 15:15:07 +0200
Message-ID: <20170826131507.GA15074@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:46418 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752183AbdHZNPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 09:15:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Reviewing Christoph's DMA patch I noticed Thomas' email address was missing
from the entire driver file.

 drivers/net/ethernet/i825xx/sni_82596.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
index 2af7f77345fb..38e0e16c9bfb 100644
--- a/drivers/net/ethernet/i825xx/sni_82596.c
+++ b/drivers/net/ethernet/i825xx/sni_82596.c
@@ -39,7 +39,7 @@ static const char sni_82596_string[] = "snirm_82596";
 
 #include "lib82596.c"
 
-MODULE_AUTHOR("Thomas Bogendoerfer");
+MODULE_AUTHOR("Thomas Bogendoerfer <tsbogend@alpha.franken.de>");
 MODULE_DESCRIPTION("i82596 driver");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:snirm_82596");
