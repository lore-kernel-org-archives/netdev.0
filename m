From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: [PATCH] doc/net: Fix typo in netdev-features.txt
Date: Sat, 10 Nov 2012 21:12:36 +0400
Message-ID: <1352567556-23326-1-git-send-email-kirr@mns.spb.ru>
Cc: netdev@vger.kernel.org, Kirill Smelkov <kirr@mns.spb.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:34013 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab2KJRLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2012 12:11:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>
---
 Documentation/networking/netdev-features.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 4164f5c..f310ede 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -164,4 +164,4 @@ read the CRC recorded by the NIC on receipt of the packet.
 This requests that the NIC receive all possible frames, including errored
 frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
 bad packets on it.  Some NICs may receive more packets if also put into normal
-PROMISC mdoe.
+PROMISC mode.
-- 
1.8.0.267.g7a4c58c
