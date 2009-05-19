From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: update version to 1.5.0-1.415
Date: Tue, 19 May 2009 22:16:11 +0200
Message-ID: <4A13138B.4090708@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1910 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753350AbZESUQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 16:16:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge driver version to 1.5.0-1.415.

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2009-04-18 12:25:35.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-05-19 22:02:12.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.4-1.412"
+#define MYRI10GE_VERSION_STR "1.5.0-1.415"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


