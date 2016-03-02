From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 05/20] ipntable: Fix typo in help text
Date: Wed,  2 Mar 2016 19:19:53 +0100
Message-ID: <1456942808-15946-6-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43329 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbcCBSVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:21:11 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 6eb84e797b263..2763570ae34d7 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -52,7 +52,7 @@ static void usage(void)
 
 		"PARMS := [ base_reachable MSEC ] [ retrans MSEC ] [ gc_stale MSEC ]\n"
 		"         [ delay_probe MSEC ] [ queue LEN ]\n"
-		"         [ app_probs VAL ] [ ucast_probes VAL ] [ mcast_probes VAL ]\n"
+		"         [ app_probes VAL ] [ ucast_probes VAL ] [ mcast_probes VAL ]\n"
 		"         [ anycast_delay MSEC ] [ proxy_delay MSEC ] [ proxy_queue LEN ]\n"
 		"         [ locktime MSEC ]\n"
 		);
-- 
2.7.2
