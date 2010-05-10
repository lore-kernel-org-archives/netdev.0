From: kaber@trash.net
Subject: [PATCH 29/84] netfilter: remove unused headers in net/ipv6/netfilter/ip6t_LOG.c
Date: Mon, 10 May 2010 22:18:00 +0200
Message-ID: <1273522735-24672-30-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54509 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab0EJUTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:05 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

Remove unused headers in net/ipv6/netfilter/ip6t_LOG.c

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/ip6t_LOG.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index b285fdf..e16c0c7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -11,7 +11,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
-- 
1.7.0.4

