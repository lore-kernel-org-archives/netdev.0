From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 2/2] flowcache: Bring net/core/flow.c under IPsec maintain scope
Date: Wed, 15 Jan 2014 15:34:14 +0800
Message-ID: <1389771254-8738-3-git-send-email-fan.du@windriver.com>
References: <1389771254-8738-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51130 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaAOHeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:34:09 -0500
In-Reply-To: <1389771254-8738-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As flow cache is mainly manipulated from IPsec.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 MAINTAINERS |    1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e11d495..14ad385 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5916,6 +5916,7 @@ L:	netdev@vger.kernel.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git
 S:	Maintained
+F:	net/core/flow.c
 F:	net/xfrm/
 F:	net/key/
 F:	net/ipv4/xfrm*
-- 
1.7.9.5
