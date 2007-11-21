From: akpm@linux-foundation.org
Subject: [patch 3/8] ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Wed, 21 Nov 2007 15:02:54 -0800
Message-ID: <200711212302.lALN2tJG013658@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Emilian.Medve@Freescale.com, davem@davemloft.net,
	galak@gate.crashing.org, leoli@Freescale.com, paulus@samba.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39005 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754210AbXKUXDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:03:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Emil Medve <Emilian.Medve@Freescale.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Kumar Gala <galak@gate.crashing.org>
Cc: Li Yang <leoli@freescale.com>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ucc_geth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes drivers/net/ucc_geth.c
--- a/drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
+++ a/drivers/net/ucc_geth.c
@@ -3443,7 +3443,7 @@ static int ucc_geth_rx(struct ucc_geth_p
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
-	struct net_device * dev;
+	struct net_device *dev;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
_
