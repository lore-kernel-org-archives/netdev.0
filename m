From: joe@perches.com
Subject: [PATCH] [125/2many] MAINTAINERS - CIRRUS LOGIC EP93XX ETHERNET
 DRIVER
Date: Sun, 12 Aug 2007 23:25:19 -0700
Message-ID: <46bff94f.XqQlvpgFqhyYcyg6%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@wantstofly.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4016 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966212AbXHMGZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:25:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index e5853e8..8b28143 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1216,6 +1216,7 @@ P:	Lennert Buytenhek
 M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/arm/ep93xx_eth.c
 
 CIRRUS LOGIC GENERIC FBDEV DRIVER
 P:	Jeff Garzik
