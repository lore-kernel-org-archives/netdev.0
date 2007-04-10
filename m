From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version to 1.3.0-1.233
Date: Tue, 10 Apr 2007 21:22:19 +0200
Message-ID: <461BE3EB.2080509@myri.com>
References: <461BE372.2000600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1783 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753174AbXDJTXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 15:23:20 -0400
In-Reply-To: <461BE372.2000600@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the myri10ge driver version number to 1.3.0-1.233.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-04-10 21:11:08.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-04-10 21:11:11.000000000 +0200
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.0-1.227"
+#define MYRI10GE_VERSION_STR "1.3.0-1.233"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


