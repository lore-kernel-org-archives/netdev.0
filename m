From: joe@perches.com
Subject: [PATCH] [114/2many] MAINTAINERS - BROADCOM TG3 GIGABIT ETHERNET
 DRIVER
Date: Sun, 12 Aug 2007 23:24:58 -0700
Message-ID: <46bff93a.pQTTtI4jcY9K0iRl%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3949 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966058AbXHMGZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:25:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 976e6d0..0ee8069 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1111,6 +1111,7 @@ P:	Michael Chan
 M:	mchan@broadcom.com
 L:	netdev@vger.kernel.org
 S:	Supported
+F:	drivers/net/tg3.*
 
 BSG (block layer generic sg v4 driver)
 P:	FUJITA Tomonori
