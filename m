From: Andreas Larsson <andreas@gaisler.com>
Subject: [PATCH] MAINTAINERS: net: Change maintainer for GRETH 10/100/1G Ethernet MAC device driver
Date: Wed, 27 Apr 2016 16:46:10 +0200
Message-ID: <1461768370-3011-1-git-send-email-andreas@gaisler.com>
Cc: linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>,
	software@gaisler.com
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp-unauthed02.binero.net ([195.74.38.227]:48085 "EHLO
	bin-vsp-out-03.atm.binero.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752194AbcD0OyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 10:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Larsson <andreas@gaisler.com>
---
 MAINTAINERS |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d5b4be..08ffebd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4903,7 +4903,7 @@ F:	net/ipv4/gre_offload.c
 F:	include/net/gre.h
 
 GRETH 10/100/1G Ethernet MAC device driver
-M:	Kristoffer Glembo <kristoffer@gaisler.com>
+M:	Andreas Larsson <andreas@gaisler.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/aeroflex/
-- 
1.7.10.4
