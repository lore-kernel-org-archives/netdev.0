From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version
Date: Mon, 11 Jun 2007 20:27:07 +0200
Message-ID: <466D93FB.5070408@myri.com>
References: <466D9380.7090605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1795 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753410AbXFKS0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:26:36 -0400
In-Reply-To: <466D9380.7090605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update myri10ge driver version to 1.3.1-1.248.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-06-11 20:04:57.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-06-11 20:05:09.000000000 +0200
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.0-1.233"
+#define MYRI10GE_VERSION_STR "1.3.1-1.248"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


