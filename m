From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] random32: assign to network folks in MAINTAINERS
Date: Thu, 27 Mar 2014 02:01:34 -0400
Message-ID: <1395900095-15254-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, tytso@mit.edu, dborkman@redhat.com,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44949 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaC0GB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 02:01:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lib/random32.c was split out of the network code and is de-facto
still maintained by the almighty net/ gods.

Make it a bit more official so that people who aren't aware of
that know where to send their patches.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e1724d5..47fd188 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6091,6 +6091,7 @@ F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
 F:	tools/net/
 F:	tools/testing/selftests/net/
+F:	lib/random32.c
 
 NETWORKING [IPv4/IPv6]
 M:	"David S. Miller" <davem@davemloft.net>
-- 
1.8.3.2
