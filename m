From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] mpls: Spelling: s/conceved/conceived/, s/as/a/
Date: Mon,  9 Mar 2015 12:54:48 +0100
Message-ID: <1425902088-20435-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from albert.telenet-ops.be ([195.130.137.90]:53596 "EHLO
	albert.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbCILys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 07:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 net/mpls/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index f4286ee7e2b03878..dfca485863e978d9 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -7,9 +7,9 @@ menuconfig MPLS
 	default n
 	---help---
 	  MultiProtocol Label Switching routes packets through logical
-	  circuits.  Originally conceved as a way of routing packets at
+	  circuits.  Originally conceived as a way of routing packets at
 	  hardware speeds (before hardware was capable of routing ipv4 packets),
-	  MPLS remains as simple way of making tunnels.
+	  MPLS remains a simple way of making tunnels.
 
 	  If you have not heard of MPLS you probably want to say N here.
 
-- 
1.9.1
