From: akpm@linux-foundation.org
Subject: [patch 1/2] MAINTAINERS: orphan FrameRelay DLCI
Date: Thu, 28 Jul 2011 13:54:23 -0700
Message-ID: <201107282054.p6SKsOik007975@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, joe@perches.com,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43797 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755038Ab1G1Uy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 16:54:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Mike McLagan hasn't contributed in many years and his email bounces.

Signed-off-by: Joe Perches <joe@perches.com>
Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 MAINTAINERS |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN MAINTAINERS~maintainers-orphan-framerelay-dlci MAINTAINERS
--- a/MAINTAINERS~maintainers-orphan-framerelay-dlci
+++ a/MAINTAINERS
@@ -2643,9 +2643,8 @@ S:	Maintained
 F:	arch/x86/math-emu/
 
 FRAME RELAY DLCI/FRAD (Sangoma drivers too)
-M:	Mike McLagan <mike.mclagan@linux.org>
 L:	netdev@vger.kernel.org
-S:	Maintained
+S:	Orphan
 F:	drivers/net/wan/dlci.c
 F:	drivers/net/wan/sdla.c
 
_
