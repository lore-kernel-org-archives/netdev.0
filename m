From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 30/66] include/net/x25device.h: Checkpatch cleanup
Date: Sat, 27 Feb 2010 17:51:11 +0100
Message-ID: <1267289508-31031-31-git-send-email-andrea.gelmini@gelma.net>
References: <1267289508-31031-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Andrea Gelmini <andrea.gelmini@gelma.net>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41119 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968647Ab0B0Qyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 11:54:50 -0500
In-Reply-To: <1267289508-31031-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/net/x25device.h:13: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 include/net/x25device.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/x25device.h b/include/net/x25device.h
index 1415bcf..246a17b 100644
--- a/include/net/x25device.h
+++ b/include/net/x25device.h
@@ -10,7 +10,7 @@ static inline __be16 x25_type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
 	skb->pkt_type = PACKET_HOST;
-	
+
 	return htons(ETH_P_X25);
 }
 #endif
-- 
1.7.0.90.g251a4

