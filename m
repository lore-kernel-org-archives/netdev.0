From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version to 1.3.0-1.225
Date: Sun, 18 Mar 2007 21:35:44 +0100
Message-ID: <45FDA2A0.4050302@myri.com>
References: <45FDA22E.1070805@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2004 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933213AbXCRUhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 16:37:35 -0400
In-Reply-To: <45FDA22E.1070805@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver version is now 1.3.0-1.225.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:21.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:23.000000000 +0100
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.2.0"
+#define MYRI10GE_VERSION_STR "1.3.0-1.225"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


