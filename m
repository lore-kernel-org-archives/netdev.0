From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] netfilter@ is subscribers-only
Date: Sun, 28 Jan 2007 15:11:08 -0800
Message-ID: <20070128151108.5e8f15ac.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, davem@davemloft.net,
	akpm <akpm@osdl.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26778 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbXA1XQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 18:16:18 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

netfilter mailing list is subscribers-only.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 MAINTAINERS |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2620-rc6.orig/MAINTAINERS
+++ linux-2620-rc6/MAINTAINERS
@@ -2290,7 +2290,7 @@ P:	Jozsef Kadlecsik
 P:	Patrick McHardy
 M:	kaber@trash.net
 L:	netfilter-devel@lists.netfilter.org
-L:	netfilter@lists.netfilter.org
+L:	netfilter@lists.netfilter.org (subscribers-only)
 L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
