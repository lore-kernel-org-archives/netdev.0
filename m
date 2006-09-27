From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version to 1.1.0
Date: Thu, 28 Sep 2006 01:12:36 +0200
Message-ID: <451B0564.6050907@myri.com>
References: <451B044A.2050404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:6644 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1031233AbWI0XMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:12:42 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <451B044A.2050404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 3/3] myri10ge: update driver version to 1.1.0

Update driver version to 1.1.0.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-09-28 01:06:00.000000000 +0200
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-09-28 01:06:05.000000000 +0200
@@ -73,7 +73,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.0.0"
+#define MYRI10GE_VERSION_STR "1.1.0"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


