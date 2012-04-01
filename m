From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 2/8] net/ipv6/addrconf_core.c: Checkpatch cleanup
Date: Sun,  1 Apr 2012 19:49:02 +0200
Message-ID: <1333302548-9187-2-git-send-email-eldad@fogrefinery.com>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49388 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab2DARtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 13:49:33 -0400
Received: by mail-ey0-f174.google.com with SMTP id q12so619984eaa.19
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 10:49:33 -0700 (PDT)
In-Reply-To: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrconf_core.c:13: ERROR: space required before the open parenthesis '('

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/addrconf_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 399287e..7981bde 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -10,7 +10,7 @@
 
 static inline unsigned ipv6_addr_scope2type(unsigned scope)
 {
-	switch(scope) {
+	switch (scope) {
 	case IPV6_ADDR_SCOPE_NODELOCAL:
 		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
 			IPV6_ADDR_LOOPBACK);
-- 
1.7.9.5
