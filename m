From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: rtpr: Fix minor typo
Date: Wed,  1 Jun 2016 21:58:21 +0200
Message-ID: <1464811101-18844-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46769 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbcFAT6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 15:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/rtpr.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/rtpr.8 b/man/man8/rtpr.8
index 5e32b2eeea537..1b04a821ae2fe 100644
--- a/man/man8/rtpr.8
+++ b/man/man8/rtpr.8
@@ -13,7 +13,7 @@ flag.
 
 .SH EXAMPLES
 .TP
-ip --onenline address show | rtpr
+ip --oneline address show | rtpr
 Undo oneline converted
 .B ip-address
 output.
-- 
2.8.2
