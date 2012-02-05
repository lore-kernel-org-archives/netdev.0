From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] bonding: Fix misspelling of "since"
Date: Mon, 6 Feb 2012 00:18:57 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202060016290.32529@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:29479 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab2BEXS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 18:18:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/bonding/bond_3ad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 0ae0d7c..793b001 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -660,7 +660,7 @@ static void __attach_bond_to_agg(struct port *port)
 static void __detach_bond_from_agg(struct port *port)
 {
 	port = NULL; /* just to satisfy the compiler */
-	// This function does nothing sience the parser/multiplexer of the receive
+	// This function does nothing since the parser/multiplexer of the receive
 	// and the parser/multiplexer of the aggregator are already combined
 }
 
-- 
1.7.9


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
