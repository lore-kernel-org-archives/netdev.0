From: Brice Goglin <brice@myri.com>
Subject: [PATCH 5/5] myri10ge: update driver version to 1.3.2-1.287
Date: Sat, 13 Oct 2007 12:34:36 +0200
Message-ID: <47109F3C.5010500@myri.com>
References: <47109E8A.8080205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1800 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753451AbXJMKfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 06:35:16 -0400
In-Reply-To: <47109E8A.8080205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The myri10ge driver is now at version 1.3.2-1.287.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-10-13 11:56:17.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-10-13 11:56:24.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.2-1.269"
+#define MYRI10GE_VERSION_STR "1.3.2-1.287"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


