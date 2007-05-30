From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version
Date: Wed, 30 May 2007 21:15:14 +0200
Message-ID: <465DCD42.7070608@myri.com>
References: <465DCCB4.5040404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1820 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753536AbXE3TPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:15:00 -0400
In-Reply-To: <465DCCB4.5040404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update driver version to 1.3.1-1.245.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-05-30 20:58:34.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-05-30 20:58:41.000000000 +0200
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.0-1.233"
+#define MYRI10GE_VERSION_STR "1.3.1-1.245"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


