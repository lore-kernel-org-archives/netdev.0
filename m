From: kaber@trash.net
Subject: [PATCH 8/8] netfilter: update netfilter git URL
Date: Tue, 30 Aug 2011 16:41:21 +0200
Message-ID: <1314715281-26233-9-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Netfilter git trees are moving to a directory shared by Pablo and
myself, update git URLs.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 MAINTAINERS |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d2e79d..a6669b2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4386,7 +4386,8 @@ L:	netfilter@vger.kernel.org
 L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/netfilter/nf-2.6.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/netfilter/nf-next-2.6.git
 S:	Supported
 F:	include/linux/netfilter*
 F:	include/linux/netfilter/
-- 
1.7.2.3

