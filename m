From: Axel Beckert <abe@deuxchevaux.org>
Subject: [PATCH] doc: Fix typo "8023.ad" in bonding documentation
Date: Thu, 5 Oct 2017 22:00:33 +0200
Message-ID: <20171005200032.GN4665@sym.noone.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
        Jiri Kosina <trivial@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:32819 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751405AbdJEUAf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 16:00:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should be "802.3ad" like everywhere else in the document.

Signed-off-by: Axel Beckert <abe@deuxchevaux.org>
---
 Documentation/networking/bonding.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 57f52cdce32e..9ba04c0bab8d 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -2387,7 +2387,7 @@ broadcast: Like active-backup, there is not much advantage to this
 	and packet type ID), so in a "gatewayed" configuration, all
 	outgoing traffic will generally use the same device.  Incoming
 	traffic may also end up on a single device, but that is
-	dependent upon the balancing policy of the peer's 8023.ad
+	dependent upon the balancing policy of the peer's 802.3ad
 	implementation.  In a "local" configuration, traffic will be
 	distributed across the devices in the bond.
 
-- 
2.14.2
