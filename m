From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: update driver version to 1.3.2-1.269
Date: Fri, 24 Aug 2007 08:57:54 +0200
Message-ID: <46CE8172.60509@myri.com>
References: <46CE8103.10109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1785 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758799AbXHXG4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 02:56:38 -0400
In-Reply-To: <46CE8103.10109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update myri10ge driver version to 1.3.2-1.269.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2007-08-24 08:45:29.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2007-08-24 08:45:38.000000000 +0200
@@ -72,7 +72,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.1-1.248"
+#define MYRI10GE_VERSION_STR "1.3.2-1.269"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


