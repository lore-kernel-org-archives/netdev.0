From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge, netem: mark mailing lists as moderated
Date: Tue,  5 Apr 2016 13:43:53 -0700
Message-ID: <1459889033-12411-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36830 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933304AbcDEUnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:43:41 -0400
Received: by mail-pa0-f50.google.com with SMTP id bx7so1469762pad.3
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 13:43:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I moderate these (lightly loaded) lists to block spam.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 67d99dd..8355536 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4303,7 +4303,7 @@ F:	drivers/net/ethernet/agere/
 
 ETHERNET BRIDGE
 M:	Stephen Hemminger <stephen@networkplumber.org>
-L:	bridge@lists.linux-foundation.org
+L:	bridge@lists.linux-foundation.org (moderated for non-subscribers)
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net:Bridge
 S:	Maintained
@@ -7576,7 +7576,7 @@ F:	drivers/infiniband/hw/nes/
 
 NETEM NETWORK EMULATOR
 M:	Stephen Hemminger <stephen@networkplumber.org>
-L:	netem@lists.linux-foundation.org
+L:	netem@lists.linux-foundation.org (moderated for non-subscribers)
 S:	Maintained
 F:	net/sched/sch_netem.c
 
-- 
2.1.4
