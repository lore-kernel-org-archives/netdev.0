From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 3/7] jme: Fix typo
Date: Mon, 6 Jul 2009 22:38:35 +0800
Message-ID: <20090706145548.B96FF38AB7@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:39383 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754687AbZGFOzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 10:55:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix enum typo in jme.h

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 0996a06..0025e68 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -247,7 +247,7 @@ enum jme_txdesc_flags_bits {
 };
 
 #define TXDESC_MSS_SHIFT	2
-enum jme_rxdescwb_flags_bits {
+enum jme_txwbdesc_flags_bits {
 	TXWBFLAG_OWN	= 0x80,
 	TXWBFLAG_INT	= 0x40,
 	TXWBFLAG_TMOUT	= 0x20,
-- 
1.6.0.6

