From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: update driver version to 1.4.4-1.395
Date: Sun, 21 Dec 2008 22:29:37 +0100
Message-ID: <494EB541.6030608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1965 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751216AbYLUV3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2008 16:29:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge driver version to 1.4.4-1.395.

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2008-12-09 12:37:59.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-12-21 22:07:52.000000000 +0100
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.378"
+#define MYRI10GE_VERSION_STR "1.4.4-1.395"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


