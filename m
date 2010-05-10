From: kaber@trash.net
Subject: [PATCH 13/84] netfilter: xt_recent: update description
Date: Mon, 10 May 2010 22:17:44 +0200
Message-ID: <1273522735-24672-14-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

It had IPv6 for quite a while already :-)

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_recent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1af74dd..bcabfbc 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -35,7 +35,7 @@
 
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
-MODULE_DESCRIPTION("Xtables: \"recently-seen\" host matching for IPv4");
+MODULE_DESCRIPTION("Xtables: \"recently-seen\" host matching");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_recent");
 MODULE_ALIAS("ip6t_recent");
-- 
1.7.0.4

