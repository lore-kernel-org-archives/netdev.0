From: Brice Goglin <brice@myri.com>
Subject: [PATCH 16/16] myri10ge: update driver version
Date: Fri, 09 May 2008 02:22:36 +0200
Message-ID: <4823994C.8060004@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1914 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757559AbYEIAWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:22:16 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge driver version to 1.4.2-1.341

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:31:15.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:31:46.000000000 +0200
@@ -76,7 +76,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.2-1.287"
+#define MYRI10GE_VERSION_STR "1.4.2-1.342"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


