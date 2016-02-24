From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 05/20] ipntable: Fix typo in help text
Date: Wed, 24 Feb 2016 09:21:18 +0100
Message-ID: <1456302093-697-6-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50975 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147AbcBXIWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:55 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
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
2.6.4
