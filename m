From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: update driver version number to 1.4.3-1.369
Date: Fri, 10 Oct 2008 23:29:51 +0200
Message-ID: <48EFC94F.40702@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1872 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761792AbYJJVbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 17:31:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge driver version number to 1.4.3-1.369.

Signed-off-by: Brice Goglin <brice@myri.com>

--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.358"
+#define MYRI10GE_VERSION_STR "1.4.3-1.369"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


