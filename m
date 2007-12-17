From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv6/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:32 -0800
Message-ID: <1197920439-5455-26-git-send-email-joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3230 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933999AbXLQTlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:41:32 -0500
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/ndisc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 67997a7..777ed73 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -612,7 +612,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 	 * optimistic addresses, but we may send the solicitation
 	 * if we don't include the sllao.  So here we check
 	 * if our address is optimistic, and if so, we
-	 * supress the inclusion of the sllao.
+	 * suppress the inclusion of the sllao.
 	 */
 	if (send_sllao) {
 		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(saddr, dev, 1);
-- 
1.5.3.7.949.g2221a6

