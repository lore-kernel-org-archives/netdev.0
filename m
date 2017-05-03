From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/16] netfilter: update MAINTAINERS file
Date: Wed,  3 May 2017 11:32:10 +0200
Message-ID: <1493803931-2837-16-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several updates on the MAINTAINERS section for Netfilter:

1) Add Florian Westphal, he's been part of the coreteam since October 2012.
   He's been dedicating tireless efforts to improve the Netfilter codebase,
   fix bugs and push ongoing new developments ever since.

2) Add http://www.nftables.org/ URL, currently pointing to
   http://www.netfilter.org.

3) Update project status from Supported to Maintained.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Florian Westphal <fw@strlen.de>
---
 MAINTAINERS | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 38d3e4ed7208..fc95cb06fb29 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8701,14 +8701,16 @@ F:	drivers/net/ethernet/neterion/
 NETFILTER
 M:	Pablo Neira Ayuso <pablo@netfilter.org>
 M:	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+M:	Florian Westphal <fw@strlen.de>
 L:	netfilter-devel@vger.kernel.org
 L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
+W:	http://www.nftables.org/
 Q:	http://patchwork.ozlabs.org/project/netfilter-devel/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git
-S:	Supported
+S:	Maintained
 F:	include/linux/netfilter*
 F:	include/linux/netfilter/
 F:	include/net/netfilter/
-- 
2.1.4

