From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] MAINTAINERS: Add extra rhashtable maintainer
Date: Thu, 18 Aug 2016 16:50:57 +0800
Message-ID: <E1baJ2P-00031B-J6@gondolin.me.apana.org.au>
References: <20160818084854.GA11502@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59205 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcHRIvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 04:51:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I'm working actively on rhashtable it helps if people CCed me
when they work on in.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 MAINTAINERS |    1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5d813a3..db09498 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9641,6 +9641,7 @@ F:	net/rfkill/
 
 RHASHTABLE
 M:	Thomas Graf <tgraf@suug.ch>
+M:	Herbert Xu <herbert@gondor.apana.org.au>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	lib/rhashtable.c
