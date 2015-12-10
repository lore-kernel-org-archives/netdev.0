From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc.8: Fix reference to tc-tcindex.8
Date: Thu, 10 Dec 2015 13:24:51 +0100
Message-ID: <1449750291-7577-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53971 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbbLJMZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 07:25:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a typo there, it's spelled correctly in SEE ALSO section..

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 6275c4b32b167..4e99dcad5b1da 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -181,7 +181,7 @@ Match Resource Reservation Protocol (RSVP) packets.
 .TP
 tcindex
 Filter packets based on traffic control index. See
-.BR tc-index (8).
+.BR tc-tcindex (8).
 .TP
 u32
 Generic filtering on arbitrary packet data, assisted by syntax to abstract common operations. See
-- 
2.5.0
