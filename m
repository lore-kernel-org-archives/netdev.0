From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.27] myri10ge: update version string to 1.4.3-1.358
Date: Tue, 26 Aug 2008 23:29:12 +0200
Message-ID: <48B475A8.7030608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1817 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751831AbYHZVa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 17:30:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge version string to 1.4.3-1.358.

Signed-off-by: Brice Goglin <brice@myri.com>
---
drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-08-24 09:54:53.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-08-26 23:21:42.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.99-1.347"
+#define MYRI10GE_VERSION_STR "1.4.3-1.358"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


