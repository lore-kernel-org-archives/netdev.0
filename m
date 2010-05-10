From: kaber@trash.net
Subject: [PATCH 17/84] netfilter: remove unused headers in net/netfilter/nfnetlink.c
Date: Mon, 10 May 2010 22:17:48 +0200
Message-ID: <1273522735-24672-18-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756690Ab0EJUTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:01 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

Remove unused headers in net/netfilter/nfnetlink.c

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 8eb0cc2..0794f9a 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -18,12 +18,9 @@
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/kernel.h>
-#include <linux/major.h>
-#include <linux/timer.h>
 #include <linux/string.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
-#include <linux/fcntl.h>
 #include <linux/skbuff.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
-- 
1.7.0.4

