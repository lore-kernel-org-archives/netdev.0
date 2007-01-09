From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: update driver version to 1.2.0
Date: Tue, 09 Jan 2007 21:05:35 +0100
Message-ID: <45A3F58F.6080803@myri.com>
References: <45A3F4FF.5000803@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-64-172-73-26.dsl.lsan03.pacbell.net ([64.172.73.26]:1798
	"EHLO myri.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932411AbXAIUa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:30:26 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45A3F4FF.5000803@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver is now at version 1.2.0.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-01-09 19:30:27.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-01-09 19:30:30.000000000 +0100
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.1.0"
+#define MYRI10GE_VERSION_STR "1.2.0"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


