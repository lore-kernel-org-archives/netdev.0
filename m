From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 2/3] TIPC: Adding new developers to maintainers list
Date: Mon, 21 May 2012 01:59:13 -0400
Message-ID: <1337579954-17161-2-git-send-email-jon.maloy@ericsson.com>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com, erik.hugne@ericsson.com,
	allan.stephens@windriver.com, maloy@donjonn.com,
	Jon Maloy <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm14-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.15]:29520
	"HELO nm14-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752488Ab2EUGGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 02:06:36 -0400
In-Reply-To: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding two very welcome new developers to maintainers list.
They have both worked with TIPC development for a while,
and are now ready to submit their own patches to net-next.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 MAINTAINERS |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 490dd6e..6f0aec8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6683,7 +6683,9 @@ F:	include/linux/wl12xx.h
 
 TIPC NETWORK LAYER
 M:	Jon Maloy <jon.maloy@ericsson.com>
+M:	Erik Hugne <erik.hugne@ericsson.com>
 M:	Allan Stephens <allan.stephens@windriver.com>
+M:	Ying Xue <ying.xue@windriver.com>
 L:	netdev@vger.kernel.org (core kernel code)
 L:	tipc-discussion@lists.sourceforge.net (user apps, general discussion)
 W:	http://tipc.sourceforge.net/
-- 
1.7.9.5
