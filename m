From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 3/4] be2net: Bump the driver version number
Date: Sat, 20 Feb 2010 05:28:21 +0530
Message-ID: <20100219235812.GA12961@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:51480 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab0BTAEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 19:04:13 -0500
Received: by gxk9 with SMTP id 9so734325gxk.8
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 16:04:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 42c7a2b..be81fb2 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -32,7 +32,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.101.346u"
+#define DRV_VER			"2.102.147u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.6.3.3

