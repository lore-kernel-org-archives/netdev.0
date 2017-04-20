From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] MAINTAINERS: Add new IPsec offloading files.
Date: Thu, 20 Apr 2017 10:36:32 +0200
Message-ID: <20170420083632.GG2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50940 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969758AbdDTIiG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:38:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds two new files to IPsec maintenance scope:

net/ipv4/esp4_offload.c
net/ipv6/ip6_offload.c

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5397f54..b01f923 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8801,12 +8801,12 @@ F:	net/core/flow.c
 F:	net/xfrm/
 F:	net/key/
 F:	net/ipv4/xfrm*
-F:	net/ipv4/esp4.c
+F:	net/ipv4/esp4*
 F:	net/ipv4/ah4.c
 F:	net/ipv4/ipcomp.c
 F:	net/ipv4/ip_vti.c
 F:	net/ipv6/xfrm*
-F:	net/ipv6/esp6.c
+F:	net/ipv6/esp6*
 F:	net/ipv6/ah6.c
 F:	net/ipv6/ipcomp6.c
 F:	net/ipv6/ip6_vti.c
-- 
2.7.4
