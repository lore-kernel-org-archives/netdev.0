From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: update MAINTAINERS file
Date: Thu, 16 May 2013 17:55:19 +0200
Message-ID: <1368719721-7470-3-git-send-email-pablo@netfilter.org>
References: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51421 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336Ab3EPPzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 11:55:32 -0400
In-Reply-To: <1368719721-7470-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Remove reference to ipchains (not any longer in the tree)
* Remove all P: (person) as this tag is obsolete according to the
  description. Therefore, update Jozsef Kadlecsik to M: so he can
  still show in the list of people.
* Add URI to Netfilter's patchwork at ozlabs.org
* Update URIs to Netfilter's git trees to point to kernel.org.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 MAINTAINERS |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index e1f5fac..32aad62 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5502,18 +5502,18 @@ F:	Documentation/networking/s2io.txt
 F:	Documentation/networking/vxge.txt
 F:	drivers/net/ethernet/neterion/
 
-NETFILTER/IPTABLES/IPCHAINS
-P:	Harald Welte
-P:	Jozsef Kadlecsik
+NETFILTER/IPTABLES
 M:	Pablo Neira Ayuso <pablo@netfilter.org>
 M:	Patrick McHardy <kaber@trash.net>
+M:	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
 L:	netfilter-devel@vger.kernel.org
 L:	netfilter@vger.kernel.org
 L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
-T:	git git://1984.lsi.us.es/nf
-T:	git git://1984.lsi.us.es/nf-next
+Q:	http://patchwork.ozlabs.org/project/netfilter-devel/list/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git
 S:	Supported
 F:	include/linux/netfilter*
 F:	include/linux/netfilter/
-- 
1.7.10.4
