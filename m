From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 4/4] flowcache: Bring net/core/flow.c under IPsec maintain scope
Date: Tue, 14 Jan 2014 09:39:47 +0800
Message-ID: <1389663588-29678-5-git-send-email-fan.du@windriver.com>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44248 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaANBjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:48 -0500
In-Reply-To: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
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
